import '../config/api_config.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import 'api_service.dart';

class ExpenseService {
  final _api = ApiService();

  Future<List<Expense>> getExpenses({
    int? category,
    String? search,
    int? month,
    int? year,
  }) async {
    final params = <String, String>{};
    if (category != null) params['category'] = category.toString();
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (month != null) params['month'] = month.toString();
    if (year != null) params['year'] = year.toString();

    final data = await _api.get(ApiConfig.expense, queryParams: params);
    final list = data is List ? data : (data['results'] ?? []);
    return (list as List).map((e) => Expense.fromJson(e)).toList();
  }

  Future<Expense> createExpense(Map<String, dynamic> body) async {
    final data = await _api.post(ApiConfig.expense, body: body);
    return Expense.fromJson(data);
  }

  Future<Expense> updateExpense(int id, Map<String, dynamic> body) async {
    final data = await _api.put('${ApiConfig.expense}$id/', body: body);
    return Expense.fromJson(data);
  }

  Future<void> deleteExpense(int id) async {
    await _api.delete('${ApiConfig.expense}$id/');
  }

  Future<List<ExpenseCategory>> getCategories() async {
    final data = await _api.get(ApiConfig.expenseCategories);
    final list = data is List ? data : (data['results'] ?? []);
    return (list as List).map((e) => ExpenseCategory.fromJson(e)).toList();
  }

  Future<ExpenseCategory> createCategory(Map<String, dynamic> body) async {
    final data = await _api.post(ApiConfig.expenseCategories, body: body);
    return ExpenseCategory.fromJson(data);
  }

  Future<void> deleteCategory(int id) async {
    await _api.delete('${ApiConfig.expenseCategories}$id/');
  }
}
