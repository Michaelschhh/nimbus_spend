import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class NotificationService {
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'nimbus_alerts',
          channelName: 'Nimbus Spend Alerts',
          channelDescription: 'Institutional financial notifications',
          defaultColor: AppColors.primary,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          criticalAlerts: true,
          onlyAlertOnce: true,
          playSound: true,
        )
      ],
      debug: true,
    );

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'nimbus_alerts',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Status, // Essential for visibility
        backgroundColor: Colors.black,
      ),
    );
  }

  static Future<void> showOverdueNotification(String itemName, double amount) async {
    await showNotification(
      id: itemName.hashCode,
      title: 'Payment Overdue!',
      body: '$itemName of \$${amount.toStringAsFixed(2)} is overdue.',
    );
  }

  static Future<void> showAutoPayNotification(String billName, double amount) async {
    await showNotification(
      id: billName.hashCode + 1,
      title: 'Bill Auto-Paid',
      body: 'Successfully auto-paid $billName for \$${amount.toStringAsFixed(2)}.',
    );
  }
}