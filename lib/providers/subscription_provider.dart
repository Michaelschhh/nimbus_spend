import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../services/storage_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  List<Subscription> _subscriptions = [];

  List<Subscription> get subscriptions => _subscriptions;

  double get monthlySubCost =>
      _subscriptions.where((s) => s.isActive).fold(0, (sum, item) {
        if (item.frequency == 'Monthly') return sum + item.amount;
        if (item.frequency == 'Weekly') return sum + (item.amount * 4);
        if (item.frequency == 'Yearly') return sum + (item.amount / 12);
        return sum + item.amount;
      });

  Future<void> fetchSubscriptions() async {
    final data = await _storage.queryAll('subscriptions');
    _subscriptions = data.map((s) => Subscription.fromMap(s)).toList();
    notifyListeners();
  }

  Future<void> addSubscription(Subscription sub) async {
    await _storage.insert('subscriptions', sub.toMap());
    _subscriptions.add(sub);
    notifyListeners();
  }

  Future<void> updateSubscription(Subscription sub) async {
    final index = _subscriptions.indexWhere((s) => s.id == sub.id);
    if (index != -1) {
      await _storage.update('subscriptions', sub.toMap(), sub.id);
      await fetchSubscriptions();
    }
  }

  Future<void> deleteSubscription(String id) async {
    await _storage.delete('subscriptions', id);
    await fetchSubscriptions();
  }

  Future<void> toggleSubscription(Subscription sub) async {
    final updated = sub.copyWith(isActive: !sub.isActive);
    await _storage.update('subscriptions', updated.toMap(), sub.id);
    final index = _subscriptions.indexWhere((s) => s.id == sub.id);
    _subscriptions[index] = updated;
    notifyListeners();
  }

  void clear() {
    _subscriptions = [];
    notifyListeners();
  }
}
