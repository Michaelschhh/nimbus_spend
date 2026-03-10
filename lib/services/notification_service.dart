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
}