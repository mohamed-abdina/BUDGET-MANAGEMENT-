import '../config/api_config.dart';
import '../models/income.dart';
import '../models/income_category.dart';
import 'api_service.dart';

class IncomeService {
  final _api = ApiService();

  Future<List<Income>> getIncomes({
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

    final data = await _api.get(ApiConfig.income, queryParams: params);
    final list = data is List ? data : (data['results'] ?? []);
    return (list as List).map((e) => Income.fromJson(e)).toList();
  }

  Future<Income> createIncome(Map<String, dynamic> body) async {
    final data = await _api.post(ApiConfig.income, body: body);
    return Income.fromJson(data);
  }

  Future<Income> updateIncome(int id, Map<String, dynamic> body) async {
    final data = await _api.put('${ApiConfig.income}$id/', body: body);
    return Income.fromJson(data);
  }

  Future<void> deleteIncome(int id) async {
    await _api.delete('${ApiConfig.income}$id/');
  }

  Future<List<IncomeCategory>> getCategories() async {
    final data = await _api.get(ApiConfig.incomeCategories);
    final list = data is List ? data : (data['results'] ?? []);
    return (list as List).map((e) => IncomeCategory.fromJson(e)).toList();
  }

  Future<IncomeCategory> createCategory(Map<String, dynamic> body) async {
    final data = await _api.post(ApiConfig.incomeCategories, body: body);
    return IncomeCategory.fromJson(data);
  }

  Future<void> deleteCategory(int id) async {
    await _api.delete('${ApiConfig.incomeCategories}$id/');
  }
}
