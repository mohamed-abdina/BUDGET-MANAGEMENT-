import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/income.dart';
import '../../providers/income_provider.dart';
import '../../utils/validators.dart';

class IncomeFormScreen extends StatefulWidget {
  final Income? income;

  const IncomeFormScreen({super.key, this.income});

  @override
  State<IncomeFormScreen> createState() => _IncomeFormScreenState();
}

class _IncomeFormScreenState extends State<IncomeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? _selectedCategory;

  bool get isEditing => widget.income != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _amountCtrl.text = widget.income!.amount.toString();
      _descCtrl.text = widget.income!.description;
      _selectedDate = widget.income!.date;
      _selectedCategory = widget.income!.category;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncomeProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<IncomeProvider>();
    final data = {
      'category': _selectedCategory,
      'amount': _amountCtrl.text,
      'description': _descCtrl.text.trim(),
      'date': _selectedDate.toIso8601String().split('T')[0],
    };

    bool success;
    if (isEditing) {
      success = await prov.updateIncome(widget.income!.id, data);
    } else {
      success = await prov.addIncome(data);
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
    final prov = context.watch<IncomeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Income' : 'Add Income'),
      ),
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
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: prov.categories.map((c) => DropdownMenuItem(
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
                  labelText: 'Amount (KES)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: Validators.amount,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (v) => Validators.required(v, 'Description'),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text('Date'),
                subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                onTap: _pickDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: prov.isLoading ? null : _save,
                child: prov.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isEditing ? 'Update' : 'Add Income'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
