import '../config/api_config.dart';
import '../models/budget.dart';
import 'api_service.dart';

class BudgetService {
  final _api = ApiService();

  Future<List<Budget>> getBudgets({int? month, int? year}) async {
    final params = <String, String>{};
    if (month != null) params['month'] = month.toString();
    if (year != null) params['year'] = year.toString();

    final data = await _api.get(ApiConfig.budgets, queryParams: params);
    final list = data is List ? data : (data['results'] ?? []);
    return (list as List).map((e) => Budget.fromJson(e)).toList();
  }

  Future<Budget> createBudget(Map<String, dynamic> body) async {
    final data = await _api.post(ApiConfig.budgets, body: body);
    return Budget.fromJson(data);
  }

  Future<Budget> updateBudget(int id, Map<String, dynamic> body) async {
    final data = await _api.put('${ApiConfig.budgets}$id/', body: body);
    return Budget.fromJson(data);
  }

  Future<void> deleteBudget(int id) async {
    await _api.delete('${ApiConfig.budgets}$id/');
  }
}
