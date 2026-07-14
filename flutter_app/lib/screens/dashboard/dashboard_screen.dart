import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/report_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/transaction_row.dart';
import '../../widgets/budget_progress_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../income/income_form_screen.dart';
import '../expenses/expense_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final incomeProv = context.read<IncomeProvider>();
    final expenseProv = context.read<ExpenseProvider>();
    final budgetProv = context.read<BudgetProvider>();
    final reportProv = context.read<ReportProvider>();

    await Future.wait([
      incomeProv.loadIncomes(month: now.month, year: now.year),
      expenseProv.loadExpenses(month: now.month, year: now.year),
      budgetProv.loadBudgets(),
      reportProv.loadSummary(month: now.month, year: now.year),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final incomeProv = context.watch<IncomeProvider>();
    final expenseProv = context.watch<ExpenseProvider>();
    final budgetProv = context.watch<BudgetProvider>();
    final reportProv = context.watch<ReportProvider>();
    final summary = reportProv.summary;

    final totalIncome = incomeProv.incomes.fold(0.0, (s, i) => s + i.amount);
    final totalExpenses = expenseProv.expenses.fold(0.0, (s, e) => s + e.amount);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const IncomeFormScreen(),
                )),
                tooltip: 'Add Income',
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const ExpenseFormScreen(),
                )),
                tooltip: 'Add Expense',
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Metrics
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        label: 'Income',
                        value: Formatters.currency(totalIncome),
                        icon: Icons.arrow_downward,
                        iconColor: AppColors.income,
                        iconBg: AppColors.incomeBg,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MetricCard(
                        label: 'Expenses',
                        value: Formatters.currency(totalExpenses),
                        icon: Icons.arrow_upward,
                        iconColor: AppColors.expense,
                        iconBg: AppColors.expenseBg,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MetricCard(
                        label: 'Balance',
                        value: Formatters.currency(totalIncome - totalExpenses),
                        icon: Icons.account_balance_wallet,
                        iconColor: AppColors.accent,
                        iconBg: AppColors.accentBg,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Budget Status
                if (budgetProv.budgets.isNotEmpty) ...[
                  Text(
                    'Budget Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...budgetProv.budgets.map((b) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                b.categoryName,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Text(
                                '${Formatters.currency(b.spent)} / ${Formatters.currency(b.amount)}',
                                style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          BudgetProgressBar(percentage: b.percentage),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 20),
                ],

                // Recent Transactions
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                if (incomeProv.incomes.isEmpty && expenseProv.expenses.isEmpty)
                  const EmptyState(
                    icon: Icons.receipt_long,
                    title: 'No transactions yet',
                    subtitle: 'Add your first income or expense',
                  )
                else
                  ..._recentTransactions(incomeProv.incomes, expenseProv.expenses),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _recentTransactions(List incomes, List expenses) {
    final all = <Map<String, dynamic>>[];
    for (final i in incomes) {
      all.add({'type': 'income', 'data': i, 'date': i.date});
    }
    for (final e in expenses) {
      all.add({'type': 'expense', 'data': e, 'date': e.date});
    }
    all.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    final recent = all.take(10).toList();

    return recent.map((item) {
      final data = item['data'];
      final isIncome = item['type'] == 'income';
      return TransactionRow(
        description: data.description,
        categoryName: data.categoryName,
        categoryColor: data.categoryColor,
        date: data.date,
        amount: data.amount,
        isIncome: isIncome,
      );
    }).toList();
  }
}
