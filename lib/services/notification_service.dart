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
          defaultColor: const Color(0xFF0A84FF),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          criticalAlerts: true,
          onlyAlertOnce: true,
          playSound: true,
        )
      ],
      debug: false,
    );

    // Set listeners so AwesomeNotifications can handle actions
    // even when the app was killed and relaunched by notification tap.
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceived,
      onNotificationCreatedMethod: _onNotificationCreated,
      onNotificationDisplayedMethod: _onNotificationDisplayed,
      onDismissActionReceivedMethod: _onDismissActionReceived,
    );
  }

  // These must be top-level or static to work in background isolates.
  @pragma('vm:entry-point')
  static Future<void> _onActionReceived(ReceivedAction receivedAction) async {}

  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreated(ReceivedNotification receivedNotification) async {}

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayed(ReceivedNotification receivedNotification) async {}

  @pragma('vm:entry-point')
  static Future<void> _onDismissActionReceived(ReceivedAction receivedAction) async {}

  static Future<void> requestPermission() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  static Future<void> scheduleItemNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    // Only schedule if date is in the future
    if (date.isBefore(DateTime.now())) return;
    
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
         id: id,
         channelKey: 'nimbus_alerts',
         title: title,
         body: body,
         notificationLayout: NotificationLayout.Default,
         category: NotificationCategory.Reminder,
         backgroundColor: Colors.black,
      ),
      schedule: NotificationCalendar(
        year: date.year, month: date.month, day: date.day, hour: 9, minute: 0, 
        allowWhileIdle: true,
        preciseAlarm: false,
        repeats: false,
      )
    );
  }

  static Future<void> cancelScheduled(int id) async {
    await AwesomeNotifications().cancel(id);
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