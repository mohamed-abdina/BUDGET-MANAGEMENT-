class MonthlyReport {
  final int month;
  final int year;
  final double income;
  final double expense;
  final double balance;

  MonthlyReport({
    required this.month,
    required this.year,
    required this.income,
    required this.expense,
    required this.balance,
  });

  factory MonthlyReport.fromJson(Map<String, dynamic> json) {
    return MonthlyReport(
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      income: (json['income'] ?? 0).toDouble(),
      expense: (json['expense'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }
}
