import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/shopping_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/shopping_list.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../utils/responsive.dart';
import 'shopping_list_screen.dart';

class ShoppingListsScreen extends StatelessWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shopProv = context.watch<ShoppingProvider>();
    final sProv = context.watch<SettingsProvider>();
    final s = sProv.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Lists", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => _createNewList(context, shopProv),
          ),
        ],
      ),
      body: shopProv.lists.isEmpty
          ? const Center(child: Text("No shopping lists yet", style: TextStyle(color: AppColors.textDim)))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: shopProv.lists.length,
              itemBuilder: (context, index) {
                final list = shopProv.lists[index];
                return _listTile(context, list, shopProv, s.currency);
              },
            ),
    );
  }

  Widget _listTile(BuildContext context, ShoppingList list, ShoppingProvider prov, String cur) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(LucideIcons.shoppingCart, color: list.isCompleted ? AppColors.success : Theme.of(context).primaryColor),
        title: Text(list.title, style: TextStyle(fontWeight: FontWeight.bold, decoration: list.isCompleted ? TextDecoration.lineThrough : null)),
        subtitle: Text("${list.date.day}/${list.date.month} • ${prov.getItems(list.id).length} items", style: const TextStyle(color: AppColors.textDim)),
        trailing: const Icon(LucideIcons.chevronRight, size: 18),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ShoppingListScreen(listId: list.id))),
      ),
    );
  }

  void _createNewList(BuildContext context, ShoppingProvider prov) {
     final controller = TextEditingController();
     showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
         title: const Text("New Shopping List"),
         content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Trip to Costco")),
         actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
           TextButton(
             onPressed: () {
               if (controller.text.isNotEmpty) {
                 prov.addList(ShoppingList(id: DateTime.now().millisecondsSinceEpoch.toString(), title: controller.text, date: DateTime.now()));
                 Navigator.pop(ctx);
               }
             }, 
             child: const Text("Create")
           ),
         ],
       )
     );
  }
}
