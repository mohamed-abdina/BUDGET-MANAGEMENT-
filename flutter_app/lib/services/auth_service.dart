import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final _api = ApiService();

  Future<Map<String, String>> login(String email, String password) async {
    final data = await _api.post(
      ApiConfig.authLogin,
      body: {'email': email, 'password': password},
    );
    await _api.setTokens(data['access'], data['refresh']);
    return {'access': data['access'], 'refresh': data['refresh']};
  }

  Future<void> register(String email, String password, String firstName) async {
    await _api.post(
      ApiConfig.authRegister,
      body: {
        'email': email,
        'password': password,
        if (firstName.isNotEmpty) 'first_name': firstName,
      },
    );
  }

  Future<User> getProfile() async {
    final data = await _api.get(ApiConfig.authProfile);
    return User.fromJson(data);
  }

  Future<User> updateProfile(Map<String, dynamic> fields) async {
    final data = await _api.patch(ApiConfig.authProfile, body: fields);
    return User.fromJson(data);
  }

  Future<void> logout() async {
    await _api.clearTokens();
  }

  Future<bool> verifyToken() async {
    try {
      await _api.post(
        ApiConfig.authVerify,
        body: {},
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
