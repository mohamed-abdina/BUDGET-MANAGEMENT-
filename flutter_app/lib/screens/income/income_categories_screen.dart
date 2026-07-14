import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/income_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';

class IncomeCategoriesScreen extends StatefulWidget {
  const IncomeCategoriesScreen({super.key});

  @override
  State<IncomeCategoriesScreen> createState() => _IncomeCategoriesScreenState();
}

class _IncomeCategoriesScreenState extends State<IncomeCategoriesScreen> {
  final _nameCtrl = TextEditingController();

  static const _presetColors = [
    '#1D8763', '#2E9E86', '#3BB88A', '#5CC89A',
    '#2670A4', '#3A88C0', '#4FA0DC', '#6BB8F0',
    '#B8862F', '#D4A043', '#E8B858', '#F0CC72',
    '#7B4BAF', '#9660C8', '#B078E0', '#C890F0',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncomeProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _addCategory() async {
    _nameCtrl.clear();
    String selectedColor = '#1D8763';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Category Name'),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text('Color', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetColors.map((hex) {
                  final clean = hex.replaceAll('#', '');
                  final color = Color(int.parse('FF$clean', radix: 16));
                  final isSelected = selectedColor == hex;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedColor = hex),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2.5)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result == true && _nameCtrl.text.trim().isNotEmpty) {
      final prov = context.read<IncomeProvider>();
      final success = await prov.addCategory({
        'name': _nameCtrl.text.trim(),
        'color': selectedColor,
      });
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(prov.error ?? 'Failed to add category'), backgroundColor: const Color(0xFFC2483F)),
        );
      }
    }
  }

  Color _parseColor(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<IncomeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Income Categories')),
      body: prov.categories.isEmpty
          ? const EmptyState(
              icon: Icons.category_outlined,
              title: 'No categories yet',
              subtitle: 'Tap + to add your first category',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: prov.categories.length,
              itemBuilder: (_, i) {
                final cat = prov.categories[i];
                final color = _parseColor(cat.color);
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.circle, color: color, size: 14),
                  ),
                  title: Text(cat.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final confirm = await showConfirmDialog(
                        context,
                        title: 'Delete Category',
                        message: 'Delete "${cat.name}"?',
                      );
                      if (confirm) prov.deleteCategory(cat.id);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }
}
