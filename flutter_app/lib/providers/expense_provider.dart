import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final _service = ExpenseService();

  List<Expense> _expenses = [];
  List<ExpenseCategory> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  List<ExpenseCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadExpenses({int? month, int? year, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _expenses = await _service.getExpenses(month: month, year: year, search: search);
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

  Future<bool> addExpense(Map<String, dynamic> data) async {
    try {
      final expense = await _service.createExpense(data);
      _expenses.insert(0, expense);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExpense(int id, Map<String, dynamic> data) async {
    try {
      final expense = await _service.updateExpense(id, data);
      final idx = _expenses.indexWhere((e) => e.id == id);
      if (idx >= 0) _expenses[idx] = expense;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      await _service.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
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
