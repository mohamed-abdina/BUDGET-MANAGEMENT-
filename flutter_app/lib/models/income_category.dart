class IncomeCategory {
  final int id;
  final String name;
  final String color;
  final String icon;

  IncomeCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  factory IncomeCategory.fromJson(Map<String, dynamic> json) {
    return IncomeCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      color: json['color'] ?? '#1D8763',
      icon: json['icon'] ?? 'ti-cash',
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
