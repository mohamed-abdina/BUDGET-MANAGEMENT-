class Expense {
  final int id;
  final int category;
  final String categoryName;
  final String categoryColor;
  final double amount;
  final String description;
  final DateTime date;

  Expense({
    required this.id,
    required this.category,
    required this.categoryName,
    required this.categoryColor,
    required this.amount,
    required this.description,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? 0,
      category: json['category'] ?? 0,
      categoryName: json['category_name'] ?? '',
      categoryColor: json['category_color'] ?? '#C2483F',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      description: json['description'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount.toStringAsFixed(2),
      'description': description,
      'date': date.toIso8601String().split('T')[0],
    };
  }
}
