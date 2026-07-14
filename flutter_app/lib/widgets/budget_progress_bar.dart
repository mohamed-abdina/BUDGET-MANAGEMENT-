import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BudgetProgressBar extends StatelessWidget {
  final double percentage;
  final double height;

  const BudgetProgressBar({
    super.key,
    required this.percentage,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final color = percentage >= 100
        ? AppColors.expense
        : percentage >= 80
            ? AppColors.accent
            : AppColors.income;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (percentage / 100).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
