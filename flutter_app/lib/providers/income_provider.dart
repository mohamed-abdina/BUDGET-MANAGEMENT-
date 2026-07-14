import 'package:flutter/material.dart';
import '../models/income.dart';
import '../models/income_category.dart';
import '../services/income_service.dart';

class IncomeProvider extends ChangeNotifier {
  final _service = IncomeService();

  List<Income> _incomes = [];
  List<IncomeCategory> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Income> get incomes => _incomes;
  List<IncomeCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadIncomes({int? month, int? year, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _incomes = await _service.getIncomes(month: month, year: year, search: search);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _service.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addIncome(Map<String, dynamic> data) async {
    try {
      final income = await _service.createIncome(data);
      _incomes.insert(0, income);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateIncome(int id, Map<String, dynamic> data) async {
    try {
      final income = await _service.updateIncome(id, data);
      final idx = _incomes.indexWhere((i) => i.id == id);
      if (idx >= 0) _incomes[idx] = income;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteIncome(int id) async {
    try {
      await _service.deleteIncome(id);
      _incomes.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addCategory(Map<String, dynamic> data) async {
    try {
      final cat = await _service.createCategory(data);
      _categories.add(cat);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await _service.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
