import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _accessToken;
  String? _refreshToken;
  String _baseUrl = ApiConfig.defaultBaseUrl;

  String get baseUrl => _baseUrl;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    _baseUrl = prefs.getString(ApiConfig.baseUrlKey) ?? ApiConfig.defaultBaseUrl;
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConfig.baseUrlKey, url);
  }

  Future<void> setTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  bool get isAuthenticated => _accessToken != null;

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConfig.authRefresh}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await setTokens(data['access'], data['refresh']);
        return true;
      }
    } catch (_) {}
    await clearTokens();
    return false;
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParams}) async {
    var uri = Uri.parse('$_baseUrl$path');
    if (queryParams != null) {
      queryParams.removeWhere((_, v) => v == null || v.isEmpty);
      uri = uri.replace(queryParameters: queryParams);
    }
    var response = await http.get(uri, headers: _headers);
    if (response.statusCode == 401 && _accessToken != null) {
      if (await _refreshAccessToken()) {
        response = await http.get(uri, headers: _headers);
      }
    }
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) async {
    var response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    if (response.statusCode == 401 && _accessToken != null) {
      if (await _refreshAccessToken()) {
        response = await http.post(
          Uri.parse('$_baseUrl$path'),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        );
      }
    }
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body}) async {
    var response = await http.put(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    if (response.statusCode == 401 && _accessToken != null) {
      if (await _refreshAccessToken()) {
        response = await http.put(
          Uri.parse('$_baseUrl$path'),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        );
      }
    }
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body}) async {
    var response = await http.patch(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    if (response.statusCode == 401 && _accessToken != null) {
      if (await _refreshAccessToken()) {
        response = await http.patch(
          Uri.parse('$_baseUrl$path'),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        );
      }
    }
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    var response = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: _headers,
    );
    if (response.statusCode == 401 && _accessToken != null) {
      if (await _refreshAccessToken()) {
        response = await http.delete(
          Uri.parse('$_baseUrl$path'),
          headers: _headers,
        );
      }
    }
    if (response.statusCode == 204) return {};
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    }
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    throw ApiException(
      statusCode: response.statusCode,
      message: body['error']?.toString() ??
          body['detail']?.toString() ??
          body['message']?.toString() ??
          'Request failed',
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}
