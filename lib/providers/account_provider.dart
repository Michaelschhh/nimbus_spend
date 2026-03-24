import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/account.dart';
import 'settings_provider.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';
import 'expense_provider.dart';

class AccountProvider extends ChangeNotifier {
  List<Account> _accounts = [];
  List<Account> get accounts => _accounts;
  bool _initialized = false;

  /// Fetches accounts AND syncs each account's balance from SharedPreferences
  Future<void> fetchAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('multi_accounts') ?? [];
    
    if (jsonList.isEmpty) {
      final defaultAccount = Account(id: 'default', name: 'Main Portfolio', icon: 'wallet', balance: 0);
      _accounts = [defaultAccount];
      await prefs.setStringList('multi_accounts', [jsonEncode(defaultAccount.toMap())]);
    } else {
      _accounts = jsonList.map((j) => Account.fromMap(jsonDecode(j))).toList();
    }

    // Sync balances from SharedPreferences (availableResources per account)
    for (int i = 0; i < _accounts.length; i++) {
      final acc = _accounts[i];
      final pfx = acc.id == 'default' ? '' : '${acc.id}_';
      final liveBalance = prefs.getDouble('${pfx}available_resources') ?? 0;
      _accounts[i] = acc.copyWith(balance: liveBalance);
    }
    await _saveAccounts();

    _initialized = true;
    notifyListeners();
  }

  /// Re-sync just the balance for all accounts (call after transfers/expense changes)
  Future<void> syncBalances() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < _accounts.length; i++) {
      final acc = _accounts[i];
      final pfx = acc.id == 'default' ? '' : '${acc.id}_';
      final liveBalance = prefs.getDouble('${pfx}available_resources') ?? 0;
      _accounts[i] = acc.copyWith(balance: liveBalance);
    }
    await _saveAccounts();
    notifyListeners();
  }

  Future<void> addAccount(Account account, SettingsProvider sProv) async {
    if (!sProv.settings.isPro && _accounts.length >= 3) {
      throw Exception("Pro-Tier Required: Free users are limited to 2 extra accounts.");
    }
    _accounts.add(account);
    await _saveAccounts();
    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
      await _saveAccounts();
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String id) async {
    if (id == 'default') throw Exception("Cannot delete the default account.");
    _accounts.removeWhere((a) => a.id == id);
    await _saveAccounts();
    notifyListeners();
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _accounts.map((a) => jsonEncode(a.toMap())).toList();
    await prefs.setStringList('multi_accounts', jsonList);
  }

  double get totalBalance => _accounts.fold(0, (sum, a) => sum + a.balance);

  Future<void> transferFunds(String fromId, String toId, double amount, SettingsProvider sProv, ExpenseProvider expProv) async {
    final prefs = await SharedPreferences.getInstance();
    final originalAccountId = sProv.currentAccountId;

    // Read live balances
    final fromPfx = fromId == 'default' ? '' : '${fromId}_';
    final toPfx = toId == 'default' ? '' : '${toId}_';
    final fromBalance = prefs.getDouble('${fromPfx}available_resources') ?? 0;

    if (fromBalance < amount) throw Exception("Insufficient funds in sender account.");

    final fromAcc = _accounts.firstWhere((a) => a.id == fromId);
    final toAcc = _accounts.firstWhere((a) => a.id == toId);

    // --- DEDUCT FROM SENDER ---
    if (originalAccountId == fromId) {
      await sProv.deductFromResources(amount);
      await expProv.addExpense(
        Expense(amount: amount, category: 'Transfer ↗️', date: DateTime.now(), note: 'Transfer to ${toAcc.name}', lifeCostHours: 0, fundingSource: 'resources'),
        sProv, skipResourceUpdate: true,
      );
    } else {
      await prefs.setDouble('${fromPfx}available_resources', (fromBalance - amount).clamp(0, double.infinity));
      await StorageService().switchDatabase(fromId);
      final e = Expense(amount: amount, category: 'Transfer ↗️', date: DateTime.now(), note: 'Transfer to ${toAcc.name}', lifeCostHours: 0, fundingSource: 'resources');
      await StorageService().insert('expenses', e.toMap());
    }

    // --- ADD TO RECEIVER ---
    if (originalAccountId == toId) {
      if (originalAccountId != fromId) await StorageService().switchDatabase(originalAccountId);
      await sProv.addToResources(amount);
      // Incoming transfers are logged as negative amount so they appear as credit
      await expProv.addExpense(
        Expense(amount: -amount, category: 'Transfer ↙️', date: DateTime.now(), note: 'Transfer from ${fromAcc.name}', lifeCostHours: 0, fundingSource: 'resources'),
        sProv, skipResourceUpdate: true,
      );
    } else {
      final toBalance = prefs.getDouble('${toPfx}available_resources') ?? 0;
      await prefs.setDouble('${toPfx}available_resources', toBalance + amount);
      await StorageService().switchDatabase(toId);
      final e = Expense(amount: -amount, category: 'Transfer ↙️', date: DateTime.now(), note: 'Transfer from ${fromAcc.name}', lifeCostHours: 0, fundingSource: 'resources');
      await StorageService().insert('expenses', e.toMap());
    }

    // Restore original database context
    await StorageService().switchDatabase(originalAccountId);

    // Sync all balances from prefs
    await syncBalances();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('multi_accounts');
    final defaultAccount = Account(id: 'default', name: 'Main Portfolio', icon: 'wallet', balance: 0);
    _accounts = [defaultAccount];
    await prefs.setStringList('multi_accounts', [jsonEncode(defaultAccount.toMap())]);
    notifyListeners();
  }
}
