import 'package:flutter/material.dart';
import '../models/report_summary.dart';
import '../models/monthly_report.dart';
import '../models/category_report.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  final _service = ReportService();

  ReportSummary? _summary;
  List<MonthlyReport> _monthly = [];
  List<CategoryReport> _categories = [];
  bool _isLoading = false;
  String? _error;

  ReportSummary? get summary => _summary;
  List<MonthlyReport> get monthly => _monthly;
  List<CategoryReport> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSummary({int? month, int? year}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _summary = await _service.getSummary(month: month, year: year);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMonthly({int months = 6}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _monthly = await _service.getMonthly(months: months);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCategories({int? month, int? year}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await _service.getCategories(month: month, year: year);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAll({int? month, int? year, int months = 6}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await Future.wait([
        _service.getSummary(month: month, year: year).then((v) => _summary = v),
        _service.getMonthly(months: months).then((v) => _monthly = v),
        _service.getCategories(month: month, year: year).then((v) => _categories = v),
      ]);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
