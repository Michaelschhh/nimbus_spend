import 'package:flutter/material.dart';
import '../models/shopping_list.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../utils/life_cost_utils.dart';
import 'settings_provider.dart';
import 'expense_provider.dart';

class ShoppingProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<ShoppingList> _lists = [];
  Map<String, List<ShoppingItem>> _itemsByList = {};

  List<ShoppingList> get lists => _lists;

  Future<void> fetchLists() async {
    final listData = await _storage.queryAll('shopping_lists');
    _lists = listData.map((l) => ShoppingList.fromMap(l)).toList();
    
    for (var list in _lists) {
      final itemData = await _storage.database.then((db) => db.query('shopping_items', where: 'listId = ?', whereArgs: [list.id]));
      _itemsByList[list.id] = itemData.map((i) => ShoppingItem.fromMap(i)).toList();
    }
    notifyListeners();
  }

  List<ShoppingItem> getItems(String listId) => _itemsByList[listId] ?? [];

  Future<void> addList(ShoppingList list) async {
    await _storage.insert('shopping_lists', list.toMap());
    _lists.add(list);
    _itemsByList[list.id] = [];
    
    // Schedule notifications
    _scheduleNotifications(list);
    
    notifyListeners();
  }

  Future<void> addItem(ShoppingItem item) async {
    double suggestedPrice = item.price;
    if (suggestedPrice == 0) {
      suggestedPrice = await getLastPrice(item.name);
    }
    
    final finalItem = item.copyWith(price: suggestedPrice);
    await _storage.insert('shopping_items', finalItem.toMap());
    _itemsByList[item.listId]?.add(finalItem);
    notifyListeners();
  }

  Future<double> getLastPrice(String name) async {
    final db = await _storage.database;
    final res = await db.query(
      'shopping_items',
      where: 'name = ? AND price > 0',
      whereArgs: [name],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (res.isNotEmpty) {
      return (res.first['price'] as num).toDouble();
    }
    return 0.0;
  }

  Future<void> updateItem(ShoppingItem item) async {
    await _storage.database.then((db) => db.update('shopping_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]));
    final list = _itemsByList[item.listId];
    if (list != null) {
      final index = list.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        list[index] = item;
      }
    }
    notifyListeners();
  }

  Future<void> deleteItem(String itemId, String listId) async {
    await _storage.database.then((db) => db.delete('shopping_items', where: 'id = ?', whereArgs: [itemId]));
    _itemsByList[listId]?.removeWhere((i) => i.id == itemId);
    notifyListeners();
  }

  Future<void> deleteList(String listId) async {
    await _storage.delete('shopping_lists', listId);
    _lists.removeWhere((l) => l.id == listId);
    _itemsByList.remove(listId);
    notifyListeners();
  }

  Future<void> checkout(String listId, String fundingSource, SettingsProvider sProv, ExpenseProvider eProv) async {
    final list = _lists.firstWhere((l) => l.id == listId);
    final items = _itemsByList[listId] ?? [];
    
    // Only count checked items
    final checkedItems = items.where((i) => i.isChecked).toList();
    final total = checkedItems.fold(0.0, (sum, i) => sum + (i.price * i.quantity));
    
    if (total > 0) {
      final expense = Expense(
        amount: total,
        category: 'Shopping',
        date: DateTime.now(),
        note: 'Checkout: ${list.title}',
        lifeCostHours: LifeCostUtils.calculate(total, sProv.settings.hourlyWage),
        fundingSource: fundingSource,
      );
      
      if (fundingSource == 'allowance') {
        await eProv.addExpense(expense, sProv, skipResourceUpdate: true);
      } else if (fundingSource == 'resources') {
        await eProv.addExpense(expense, sProv, skipResourceUpdate: true);
        await sProv.deductFromResources(total);
      }
    }
    
    // Mark list as completed
    final updatedList = list.copyWith(isCompleted: true);
    await _storage.update('shopping_lists', updatedList.toMap(), listId);
    final index = _lists.indexWhere((l) => l.id == listId);
    if (index != -1) {
      _lists[index] = updatedList;
    }
    notifyListeners();
  }

  void _scheduleNotifications(ShoppingList list) {
    // Reminder the day before
    NotificationService.scheduleItemNotification(
      id: list.id.hashCode,
      title: "Upcoming Shopping Trip",
      body: "Don't forget: ${list.title} is scheduled for tomorrow!",
      date: list.date.subtract(const Duration(days: 1)),
    );
    
    // Reminder on the day
    NotificationService.scheduleItemNotification(
      id: list.id.hashCode + 1,
      title: "Time to Shop!",
      body: "Your shopping list '${list.title}' is ready for today.",
      date: list.date,
    );
  }

  Future<void> clear() async {
    await _storage.clearTable('shopping_lists');
    await _storage.clearTable('shopping_items');
    _lists.clear();
    _itemsByList.clear();
    notifyListeners();
  }
}
