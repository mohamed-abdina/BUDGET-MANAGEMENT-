import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/report_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    context.read<ReportProvider>().loadAll(month: _selectedMonth, year: _selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ReportProvider>();
    final summary = prov.summary;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: prov.isLoading
            ? const LoadingIndicator()
            : summary == null
                ? const EmptyState(
                    icon: Icons.bar_chart,
                    title: 'No data available',
                    subtitle: 'Add some income or expenses first',
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Month selector
                      Row(
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
                      const SizedBox(height: 8),

                      // Summary cards
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              label: 'Income',
                              value: Formatters.currency(summary.income),
                              icon: Icons.arrow_downward,
                              iconColor: AppColors.income,
                              iconBg: AppColors.incomeBg,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MetricCard(
                              label: 'Expenses',
                              value: Formatters.currency(summary.expenses),
                              icon: Icons.arrow_upward,
                              iconColor: AppColors.expense,
                              iconBg: AppColors.expenseBg,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MetricCard(
                              label: 'Balance',
                              value: Formatters.currency(summary.balance),
                              icon: Icons.account_balance_wallet,
                              iconColor: AppColors.accent,
                              iconBg: AppColors.accentBg,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Monthly trend chart
                      if (prov.monthly.isNotEmpty) ...[
                        Text(
                          'Monthly Trend',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: prov.monthly
                                      .map((m) => [m.income, m.expense])
                                      .expand((e) => e)
                                      .reduce((a, b) => a > b ? a : b) * 1.2,
                                  barGroups: prov.monthly.asMap().entries.map((entry) {
                                    final i = entry.key;
                                    final m = entry.value;
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: m.income,
                                          color: AppColors.income,
                                          width: 12,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                        ),
                                        BarChartRodData(
                                          toY: m.expense,
                                          color: AppColors.expense,
                                          width: 12,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, _) {
                                          final idx = value.toInt();
                                          if (idx < 0 || idx >= prov.monthly.length) return const SizedBox();
                                          final m = prov.monthly[idx];
                                          return Text(
                                            Formatters.monthShort(m.month),
                                            style: const TextStyle(fontSize: 11),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: const FlGridData(show: false),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Category breakdown
                      if (prov.categories.isNotEmpty) ...[
                        Text(
                          'Spending by Category',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sections: prov.categories.map((c) {
                                    final clean = c.categoryColor.replaceAll('#', '');
                                    return PieChartSectionData(
                                      value: c.total,
                                      color: Color(int.parse('FF$clean', radix: 16)),
                                      title: c.categoryName,
                                      titleStyle: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      radius: 80,
                                    );
                                  }).toList(),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...prov.categories.map((c) {
                          final clean = c.categoryColor.replaceAll('#', '');
                          final color = Color(int.parse('FF$clean', radix: 16));
                          return ListTile(
                            leading: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            title: Text(c.categoryName),
                            trailing: Text(
                              Formatters.currency(c.total),
                              style: const TextStyle(fontFamily: 'RobotoMono', fontWeight: FontWeight.w600),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
      ),
    );
  }
}
