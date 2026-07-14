class CategoryReport {
  final String categoryName;
  final String categoryColor;
  final double total;

  CategoryReport({
    required this.categoryName,
    required this.categoryColor,
    required this.total,
  });

  factory CategoryReport.fromJson(Map<String, dynamic> json) {
    return CategoryReport(
      categoryName: json['category__name'] ?? '',
      categoryColor: json['category__color'] ?? '#C2483F',
      total: double.tryParse(json['total'].toString()) ?? 0.0,
    );
  }
}
