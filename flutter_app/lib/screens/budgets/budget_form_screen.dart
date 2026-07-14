import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/budget.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/validators.dart';

class BudgetFormScreen extends StatefulWidget {
  final Budget? budget;

  const BudgetFormScreen({super.key, this.budget});

  @override
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  int? _selectedCategory;
  late int _selectedMonth;
  late int _selectedYear;

  bool get isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    final budgetProv = context.read<BudgetProvider>();
    if (isEditing) {
      _amountCtrl.text = widget.budget!.amount.toString();
      _selectedCategory = widget.budget!.category;
      _selectedMonth = widget.budget!.month;
      _selectedYear = widget.budget!.year;
    } else {
      _selectedMonth = budgetProv.selectedMonth;
      _selectedYear = budgetProv.selectedYear;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<BudgetProvider>();
    final data = {
      'category': _selectedCategory,
      'amount': _amountCtrl.text,
      'month': _selectedMonth,
      'year': _selectedYear,
    };

    bool success;
    if (isEditing) {
      success = await prov.updateBudget(widget.budget!.id, data);
    } else {
      success = await prov.addBudget(data);
    }

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(prov.error ?? 'Failed'), backgroundColor: const Color(0xFFC2483F)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProv = context.watch<ExpenseProvider>();
    final budgetProv = context.watch<BudgetProvider>();
    final existingCatIds = budgetProv.budgets
        .where((b) => !isEditing || b.id != widget.budget!.id)
        .map((b) => b.category)
        .toSet();
    final availableCategories = expenseProv.categories
        .where((c) => !existingCatIds.contains(c.id))
        .toList();

    // If editing, ensure the current category is in the list
    if (isEditing && _selectedCategory != null) {
      final currentCat = expenseProv.categories
          .where((c) => c.id == _selectedCategory)
          .toList();
      if (currentCat.isNotEmpty && !availableCategories.any((c) => c.id == _selectedCategory)) {
        availableCategories.insert(0, currentCat.first);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Budget' : 'Add Budget')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Expense Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: availableCategories.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name),
                )).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(
                  labelText: 'Budget Amount (KES)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: Validators.amount,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      decoration: const InputDecoration(
                        labelText: 'Month',
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                      items: List.generate(12, (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text([
                          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                        ][i]),
                      )),
                      onChanged: (v) => setState(() => _selectedMonth = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Year',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: List.generate(5, (i) => DropdownMenuItem(
                        value: DateTime.now().year - 2 + i,
                        child: Text('${DateTime.now().year - 2 + i}'),
                      )),
                      onChanged: (v) => setState(() => _selectedYear = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: budgetProv.isLoading ? null : _save,
                child: budgetProv.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isEditing ? 'Update Budget' : 'Create Budget'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
