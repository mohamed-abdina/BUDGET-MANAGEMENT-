import '../config/api_config.dart';
import '../models/report_summary.dart';
import '../models/monthly_report.dart';
import '../models/category_report.dart';
import 'api_service.dart';

class ReportService {
  final _api = ApiService();

  Future<ReportSummary> getSummary({int? month, int? year}) async {
    final params = <String, String>{};
    if (month != null) params['month'] = month.toString();
    if (year != null) params['year'] = year.toString();

    final data = await _api.get(ApiConfig.reportsSummary, queryParams: params);
    return ReportSummary.fromJson(data);
  }

  Future<List<MonthlyReport>> getMonthly({int months = 6}) async {
    final data = await _api.get(
      ApiConfig.reportsMonthly,
      queryParams: {'months': months.toString()},
    );
    final list = data is List ? data : [];
    return (list as List).map((e) => MonthlyReport.fromJson(e)).toList();
  }

  Future<List<CategoryReport>> getCategories({int? month, int? year}) async {
    final params = <String, String>{};
    if (month != null) params['month'] = month.toString();
    if (year != null) params['year'] = year.toString();

    final data = await _api.get(ApiConfig.reportsCategories, queryParams: params);
    final list = data is List ? data : [];
    return (list as List).map((e) => CategoryReport.fromJson(e)).toList();
  }
}
