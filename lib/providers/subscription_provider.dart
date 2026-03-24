import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../utils/date_utils.dart';

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
    _subscriptions.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    notifyListeners();
  }

  Future<void> addSubscription(Subscription sub) async {
    await _storage.insert('subscriptions', sub.toMap());
    _subscriptions.add(sub);
    _scheduleSubNotifications(sub);
    notifyListeners();
  }

  Future<void> updateSubscription(Subscription sub) async {
    final index = _subscriptions.indexWhere((s) => s.id == sub.id);
    if (index != -1) {
      await _storage.update('subscriptions', sub.toMap(), sub.id);
      NotificationService.cancelScheduled(sub.id.hashCode);
      NotificationService.cancelScheduled(sub.id.hashCode + 1);
      if (sub.isActive) {
        _scheduleSubNotifications(sub);
      }
      await fetchSubscriptions();
    }
  }

  Future<void> deleteSubscription(String id) async {
    await _storage.delete('subscriptions', id);
    NotificationService.cancelScheduled(id.hashCode);
    NotificationService.cancelScheduled(id.hashCode + 1);
    await fetchSubscriptions();
  }

  Future<void> toggleSubscription(Subscription sub) async {
    final updated = sub.copyWith(isActive: !sub.isActive);
    await updateSubscription(updated);
  }

  void _scheduleSubNotifications(Subscription sub) {
    if (!sub.isActive) return;
    
    NotificationService.scheduleItemNotification(
      id: sub.id.hashCode,
      title: 'Subscription Renewal Today!',
      body: '${sub.name} for \$${sub.amount.toStringAsFixed(2)} renews today.',
      date: sub.nextDueDate,
    );
    
    final reminderDate = sub.nextDueDate.subtract(const Duration(days: 3));
    NotificationService.scheduleItemNotification(
      id: sub.id.hashCode + 1,
      title: 'Subscription Renews Soon',
      body: '${sub.name} for \$${sub.amount.toStringAsFixed(2)} renews in 3 days.',
      date: reminderDate,
    );
  }

  void clear() {
    _subscriptions = [];
    notifyListeners();
  }
}
