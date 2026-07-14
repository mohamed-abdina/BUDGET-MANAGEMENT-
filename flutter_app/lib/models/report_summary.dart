class ReportSummary {
  final double income;
  final double expenses;
  final double balance;
  final int month;
  final int year;

  ReportSummary({
    required this.income,
    required this.expenses,
    required this.balance,
    required this.month,
    required this.year,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      income: (json['income'] ?? 0).toDouble(),
      expenses: (json['expenses'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
      month: json['month'] ?? DateTime.now().month,
      year: json['year'] ?? DateTime.now().year,
    );
  }
}
