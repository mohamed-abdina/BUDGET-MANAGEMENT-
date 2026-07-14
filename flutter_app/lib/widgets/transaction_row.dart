import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class TransactionRow extends StatelessWidget {
  final String description;
  final String categoryName;
  final String categoryColor;
  final DateTime date;
  final double amount;
  final bool isIncome;
  final VoidCallback? onTap;

  const TransactionRow({
    super.key,
    required this.description,
    required this.categoryName,
    required this.categoryColor,
    required this.date,
    required this.amount,
    required this.isIncome,
    this.onTap,
  });

  Color _parseColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(categoryColor);
    final amountColor = isIncome ? const Color(0xFF1D8763) : const Color(0xFFC2483F);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$categoryName \u00B7 ${Formatters.date(date)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isIncome ? '+' : '-'}${Formatters.currency(amount)}',
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontWeight: FontWeight.w600,
                color: amountColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
