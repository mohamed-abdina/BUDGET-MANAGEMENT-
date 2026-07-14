import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/transaction_row.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/confirm_dialog.dart';
import 'expense_form_screen.dart';
import 'expense_categories_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    context.read<ExpenseProvider>().loadExpenses(
      month: _selectedMonth,
      year: _selectedYear,
      search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ExpenseProvider>();
    final total = prov.expenses.fold(0.0, (s, e) => s + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const ExpenseCategoriesScreen(),
            )),
            tooltip: 'Categories',
          ),
        ],
      ),
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
                    setState(() {
                      _selectedMonth--;
                      if (_selectedMonth < 1) {
                        _selectedMonth = 12;
                        _selectedYear--;
                      }
                    });
                    _load();
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      Formatters.month(_selectedMonth, _selectedYear),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedMonth++;
                      if (_selectedMonth > 12) {
                        _selectedMonth = 1;
                        _selectedYear++;
                      }
                    });
                    _load();
                  },
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          _load();
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (_) => _load(),
              onChanged: (_) => setState(() {}),
            ),
          ),
          // Total
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Total: ',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                Text(
                  Formatters.currency(total),
                  style: const TextStyle(
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC2483F),
                  ),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: prov.isLoading
                ? const LoadingIndicator()
                : prov.expenses.isEmpty
                    ? const EmptyState(
                        icon: Icons.arrow_upward,
                        title: 'No expenses yet',
                        subtitle: 'Tap + to add your first expense',
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: prov.expenses.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final expense = prov.expenses[i];
                            return Dismissible(
                              key: Key('expense_${expense.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: const Color(0xFFC2483F),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (_) => showConfirmDialog(
                                context,
                                title: 'Delete Expense',
                                message: 'Delete "${expense.description}"?',
                              ),
                              onDismissed: (_) async {
                                await prov.deleteExpense(expense.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Expense deleted')),
                                  );
                                }
                              },
                              child: TransactionRow(
                                description: expense.description,
                                categoryName: expense.categoryName,
                                categoryColor: expense.categoryColor,
                                date: expense.date,
                                amount: expense.amount,
                                isIncome: false,
                                onTap: () => Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => ExpenseFormScreen(expense: expense),
                                )),
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
          builder: (_) => const ExpenseFormScreen(),
        )),
        child: const Icon(Icons.add),
      ),
    );
  }
}
