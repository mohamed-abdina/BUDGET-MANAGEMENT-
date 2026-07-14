import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/budget_progress_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/confirm_dialog.dart';
import 'budget_form_screen.dart';

class BudgetListScreen extends StatefulWidget {
  const BudgetListScreen({super.key});

  @override
  State<BudgetListScreen> createState() => _BudgetListScreenState();
}

class _BudgetListScreenState extends State<BudgetListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    context.read<BudgetProvider>().loadBudgets();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<BudgetProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: Column(
        children: [
          // Month/Year selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    var m = prov.selectedMonth - 1;
                    var y = prov.selectedYear;
                    if (m < 1) { m = 12; y--; }
                    prov.setSelectedMonth(m, y);
                    _load();
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      Formatters.month(prov.selectedMonth, prov.selectedYear),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    var m = prov.selectedMonth + 1;
                    var y = prov.selectedYear;
                    if (m > 12) { m = 1; y++; }
                    prov.setSelectedMonth(m, y);
                    _load();
                  },
                ),
              ],
            ),
          ),
          // Summary
          if (prov.budgets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryItem('Budget', Formatters.currency(prov.totalBudget)),
                      _summaryItem('Spent', Formatters.currency(prov.totalSpent)),
                      _summaryItem('Remaining', Formatters.currency(prov.totalRemaining)),
                    ],
                  ),
                ),
              ),
            ),
          // Budget list
          Expanded(
            child: prov.isLoading
                ? const LoadingIndicator()
                : prov.budgets.isEmpty
                    ? const EmptyState(
                        icon: Icons.pie_chart_outline,
                        title: 'No budgets set',
                        subtitle: 'Tap + to create a budget',
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: prov.budgets.length,
                          itemBuilder: (_, i) {
                            final budget = prov.budgets[i];
                            return Card(
                              child: InkWell(
                                onTap: () => Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => BudgetFormScreen(budget: budget),
                                )).then((_) => _load()),
                                borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          budget.categoryName,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                        ),
                                        const Spacer(),
                                        PopupMenuButton(
                                          itemBuilder: (_) => [
                                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                          ],
                                          onSelected: (v) async {
                                            if (v == 'edit') {
                                              Navigator.push(context, MaterialPageRoute(
                                                builder: (_) => BudgetFormScreen(budget: budget),
                                              )).then((_) => _load());
                                            } else if (v == 'delete') {
                                              final confirm = await showConfirmDialog(
                                                context,
                                                title: 'Delete Budget',
                                                message: 'Delete budget for "${budget.categoryName}"?',
                                              );
                                              if (confirm) {
                                                await prov.deleteBudget(budget.id);
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Budget deleted')),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          'Spent: ${Formatters.currency(budget.spent)}',
                                          style: TextStyle(
                                            fontFamily: 'RobotoMono',
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          'Limit: ${Formatters.currency(budget.amount)}',
                                          style: TextStyle(
                                            fontFamily: 'RobotoMono',
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${budget.percentage.toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            fontFamily: 'RobotoMono',
                                            fontWeight: FontWeight.w600,
                                            color: budget.percentage >= 100
                                                ? const Color(0xFFC2483F)
                                                : budget.percentage >= 80
                                                    ? const Color(0xFFB8862F)
                                                    : const Color(0xFF1D8763),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    BudgetProgressBar(percentage: budget.percentage),
                                  ],
                                ),
                              ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const BudgetFormScreen(),
        )).then((_) => _load()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'RobotoMono',
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
