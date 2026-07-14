class Budget {
  final int id;
  final int category;
  final String categoryName;
  final String categoryColor;
  final double amount;
  final int month;
  final int year;
  final double spent;
  final double remaining;
  final double percentage;

  Budget({
    required this.id,
    required this.category,
    required this.categoryName,
    required this.categoryColor,
    required this.amount,
    required this.month,
    required this.year,
    required this.spent,
    required this.remaining,
    required this.percentage,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] ?? 0,
      category: json['category'] ?? 0,
      categoryName: json['category_name'] ?? '',
      categoryColor: json['category_color'] ?? '#C2483F',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      month: json['month'] ?? 1,
      year: json['year'] ?? DateTime.now().year,
      spent: double.tryParse(json['spent'].toString()) ?? 0.0,
      remaining: double.tryParse(json['remaining'].toString()) ?? 0.0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount.toStringAsFixed(2),
      'month': month,
      'year': year,
    };
  }
}
