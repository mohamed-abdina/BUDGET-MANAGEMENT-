import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/income_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/transaction_row.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/confirm_dialog.dart';
import 'income_form_screen.dart';
import 'income_categories_screen.dart';

class IncomeListScreen extends StatefulWidget {
  const IncomeListScreen({super.key});

  @override
  State<IncomeListScreen> createState() => _IncomeListScreenState();
}

class _IncomeListScreenState extends State<IncomeListScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    context.read<IncomeProvider>().loadIncomes(
      month: _selectedMonth,
      year: _selectedYear,
      search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<IncomeProvider>();
    final total = prov.incomes.fold(0.0, (s, i) => s + i.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => const IncomeCategoriesScreen(),
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
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D8763),
                  ),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: prov.isLoading
                ? const LoadingIndicator()
                : prov.incomes.isEmpty
                    ? const EmptyState(
                        icon: Icons.arrow_downward,
                        title: 'No income entries',
                        subtitle: 'Tap + to add your first income',
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: prov.incomes.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final income = prov.incomes[i];
                            return Dismissible(
                              key: Key('income_${income.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: const Color(0xFFC2483F),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              confirmDismiss: (_) => showConfirmDialog(
                                context,
                                title: 'Delete Income',
                                message: 'Delete "${income.description}"?',
                              ),
                              onDismissed: (_) async {
                                await prov.deleteIncome(income.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Income deleted')),
                                  );
                                }
                              },
                              child: TransactionRow(
                                description: income.description,
                                categoryName: income.categoryName,
                                categoryColor: income.categoryColor,
                                date: income.date,
                                amount: income.amount,
                                isIncome: true,
                                onTap: () => Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => IncomeFormScreen(income: income),
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
          builder: (_) => const IncomeFormScreen(),
        )),
        child: const Icon(Icons.add),
      ),
    );
  }
}
