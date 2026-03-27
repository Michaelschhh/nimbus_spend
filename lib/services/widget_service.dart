import 'package:home_widget/home_widget.dart';
import 'package:flutter/services.dart';

class WidgetService {
  static const String _groupId = 'group.com.example.nimbus_spend'; // Must match native side
  static const String _androidWidgetName = 'NimbusWidget';
  
  static Future<void> updateWidgetData({
    required double monthlyAllowance,
    required double spentToday,
    required String currency,
    required Color primaryColor,
    required Color backgroundColor,
    required Color textColor,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('monthlyAllowance', monthlyAllowance.toStringAsFixed(2));
      await HomeWidget.saveWidgetData<String>('spentToday', spentToday.toStringAsFixed(2));
      await HomeWidget.saveWidgetData<String>('currency', currency);
      await HomeWidget.saveWidgetData<String>('primaryColor', '#${primaryColor.value.toRadixString(16).padLeft(8, '0')}');
      await HomeWidget.saveWidgetData<String>('backgroundColor', '#${backgroundColor.value.toRadixString(16).padLeft(8, '0')}');
      await HomeWidget.saveWidgetData<String>('textColor', '#${textColor.value.toRadixString(16).padLeft(8, '0')}');
      
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
