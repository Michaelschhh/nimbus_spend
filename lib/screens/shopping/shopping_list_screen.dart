import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/shopping_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/shopping_list.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../services/sound_service.dart';

class ShoppingListScreen extends StatelessWidget {
  final String listId;
  const ShoppingListScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    final shopProv = context.watch<ShoppingProvider>();
    final eProv = context.read<ExpenseProvider>();
    final sProv = context.read<SettingsProvider>();
    
    final list = shopProv.lists.firstWhere((l) => l.id == listId);
    final items = shopProv.getItems(listId);
    final allChecked = items.isNotEmpty && items.every((i) => i.isChecked);
    
    double total = items.where((i) => i.isChecked).fold(0.0, (sum, i) => sum + (i.price * i.quantity));

    return Scaffold(
      appBar: AppBar(
        title: Text(list.title),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: AppColors.danger),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Delete List?"),
                  content: Text(total > 0 
                    ? "Do you want to log these checked items as an expense before deleting, or permanently delete the list without logging?"
                    : "Are you sure you want to permanently delete this list?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                    if (total > 0)
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showCheckoutPrompt(context, shopProv, eProv, sProv, total);
                        },
                        child: const Text("Log Expense", style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))
                      ),
                    TextButton(
                      onPressed: () {
                        shopProv.deleteList(listId);
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: Text(total > 0 ? "Delete Without Logging" : "Delete", style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold))
                    ),
                  ],
                )
              );
            },
          ),
          if (allChecked && !list.isCompleted)
            TextButton.icon(
              onPressed: () => _showCheckoutPrompt(context, shopProv, eProv, sProv, total),
              icon: const Icon(LucideIcons.checkCircle2, color: AppColors.success),
              label: const Text("Checkout", style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          if (items.isEmpty)
             const Expanded(child: Center(child: Text("List is empty", style: TextStyle(color: AppColors.textDim))))
          else
             Expanded(
               child: ListView.builder(
                 padding: const EdgeInsets.all(24),
                 itemCount: items.length,
                 itemBuilder: (context, index) {
                   final item = items[index];
                   return _itemTile(context, item, shopProv);
                 },
               ),
             ),
          _addItemBar(context, shopProv),
        ],
      ),
    );
  }

  Widget _itemTile(BuildContext context, ShoppingItem item, ShoppingProvider prov) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Checkbox(
          value: item.isChecked,
          onChanged: (val) {
            prov.updateItem(item.copyWith(isChecked: val ?? false));
            if (val == true) SoundService.tap();
          },
        ),
        title: Text(item.name, style: TextStyle(decoration: item.isChecked ? TextDecoration.lineThrough : null)),
        subtitle: Text("${item.quantity} x ${Formatters.currency(item.price, 'USD')}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(LucideIcons.edit3, size: 18, color: AppColors.textDim),
              onPressed: () => _showEditItemDialog(context, item, prov),
            ),
            IconButton(
              icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.danger),
              onPressed: () => prov.deleteItem(item.id, listId),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, ShoppingItem item, ShoppingProvider prov) {
    final qty = TextEditingController(text: item.quantity.toString());
    final price = TextEditingController(text: item.price.toString());
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit ${item.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: qty, decoration: const InputDecoration(labelText: "Quantity"), keyboardType: TextInputType.number),
            TextField(controller: price, decoration: const InputDecoration(labelText: "Price per unit"), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              prov.updateItem(item.copyWith(
                quantity: int.tryParse(qty.text) ?? item.quantity,
                price: double.tryParse(price.text) ?? item.price,
              ));
              Navigator.pop(ctx);
            }, 
            child: const Text("Save")
          ),
        ],
      )
    );
  }

  Widget _addItemBar(BuildContext context, ShoppingProvider prov) {
    final name = TextEditingController();
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: name,
              decoration: const InputDecoration(hintText: "Add item...", border: InputBorder.none),
              onSubmitted: (val) {
                if (val.isNotEmpty) {
                  prov.addItem(ShoppingItem(id: DateTime.now().millisecondsSinceEpoch.toString(), listId: listId, name: val, quantity: 1, price: 0));
                  name.clear();
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () {
               if (name.text.isNotEmpty) {
                  prov.addItem(ShoppingItem(id: DateTime.now().millisecondsSinceEpoch.toString(), listId: listId, name: name.text, quantity: 1, price: 0));
                  name.clear();
               }
            },
          ),
        ],
      ),
    );
  }

  void _showCheckoutPrompt(BuildContext context, ShoppingProvider prov, ExpenseProvider eProv, SettingsProvider sProv, double total) {
    String selectedSource = sProv.settings.hasMonthlyAllowance ? 'allowance' : 'resources';
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Convert to Expense?"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Log \$${total.toStringAsFixed(2)} as a shopping expense?"),
                const SizedBox(height: 20),
                const Text("Debit from:", style: TextStyle(fontWeight: FontWeight.bold)),
                if (sProv.settings.hasMonthlyAllowance)
                  RadioListTile<String>(
                    title: const Text("Monthly Allowance"),
                    value: 'allowance',
                    groupValue: selectedSource,
                    onChanged: (val) => setState(() => selectedSource = val!),
                  ),
                RadioListTile<String>(
                  title: const Text("Available Resources"),
                  value: 'resources',
                  groupValue: selectedSource,
                  onChanged: (val) => setState(() => selectedSource = val!),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              TextButton(
                onPressed: () async {
                  await prov.checkout(listId, selectedSource, sProv, eProv);
                  Navigator.pop(ctx);
                  Navigator.pop(context); // Go back to lists
                  SoundService.success();
                }, 
                child: const Text("Log Expense", style: TextStyle(fontWeight: FontWeight.bold))
              ),
            ],
          );
        }
      )
    );
  }
}
