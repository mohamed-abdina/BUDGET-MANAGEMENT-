class ApiConfig {
  static const String defaultBaseUrl = 'http://10.0.2.2:8000';
  static const String baseUrlKey = 'base_url';

  static const String authLogin = '/api/auth/login/';
  static const String authRegister = '/api/auth/register/';
  static const String authRefresh = '/api/auth/refresh/';
  static const String authVerify = '/api/auth/verify/';
  static const String authProfile = '/api/auth/profile/';

  static const String income = '/api/income/';
  static const String incomeCategories = '/api/income/categories/';

  static const String expense = '/api/expense/';
  static const String expenseCategories = '/api/expense/categories/';

  static const String budgets = '/api/budgets/';

  static const String reportsSummary = '/api/reports/summary/';
  static const String reportsMonthly = '/api/reports/monthly/';
  static const String reportsCategories = '/api/reports/categories/';
}
