import 'package:home_widget/home_widget.dart';
import 'package:flutter/services.dart';

class WidgetService {
  static const String _groupId = 'group.com.example.nimbus_spend'; // Must match native side
  static const String _androidWidgetName = 'NimbusWidget';
  
  static Future<void> updateWidgetData({
    required double balance,
    required double spentToday,
    required String currency,
  }) async {
    try {
      await HomeWidget.saveWidgetData<double>('balance', balance);
      await HomeWidget.saveWidgetData<double>('spentToday', spentToday);
      await HomeWidget.saveWidgetData<String>('currency', currency);
      
      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
        iOSName: 'NimbusWidget',
      );
    } on PlatformException catch (e) {
      print('Widget update failed: $e');
    }
  }
}
