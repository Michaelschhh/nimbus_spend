import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../theme/colors.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: initAndroid);
    await _plugin.initialize(initSettings);
  }

  static Future<void> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }
  }

  static Future<void> scheduleItemNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    if (date.isBefore(DateTime.now())) return;
    
    // Set for 9 AM of that date
    final scheduleTime = DateTime(date.year, date.month, date.day, 9, 0);
    if (scheduleTime.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduleTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'nimbus_alerts',
          'Nimbus Spend Alerts',
          channelDescription: 'Institutional financial notifications',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFF0A84FF),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelScheduled(int id) async {
    await _plugin.cancel(id);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'nimbus_alerts',
          'Nimbus Spend Alerts',
          channelDescription: 'Institutional financial notifications',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFF0A84FF),
        ),
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