class ExpenseCategory {
  final int id;
  final String name;
  final String color;
  final String icon;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      color: json['color'] ?? '#C2483F',
      icon: json['icon'] ?? 'ti-shopping-cart',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color,
      'icon': icon,
    };
  }
}
