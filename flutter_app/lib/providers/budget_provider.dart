import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  final _service = BudgetService();

  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  void setSelectedMonth(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();
  }

  Future<void> loadBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _budgets = await _service.getBudgets(month: _selectedMonth, year: _selectedYear);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addBudget(Map<String, dynamic> data) async {
    try {
      final budget = await _service.createBudget(data);
      _budgets.add(budget);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBudget(int id, Map<String, dynamic> data) async {
    try {
      final budget = await _service.updateBudget(id, data);
      final idx = _budgets.indexWhere((b) => b.id == id);
      if (idx >= 0) _budgets[idx] = budget;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBudget(int id) async {
    try {
      await _service.deleteBudget(id);
      _budgets.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  double get totalBudget => _budgets.fold(0.0, (sum, b) => sum + b.amount);
  double get totalSpent => _budgets.fold(0.0, (sum, b) => sum + b.spent);
  double get totalRemaining => totalBudget - totalSpent;
}
