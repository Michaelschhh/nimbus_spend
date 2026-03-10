import 'package:shared_preferences/shared_preferences.dart';

class IAPService {
  // Silent backend placeholder
  static const String removeAdsProductId = 'remove_ads_nimbus';

  static Future<bool> get isAdFree async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('ads_removed') ?? false;
  }

  static Future<void> purchaseRemoveAds() async {
    // TODO: Implement with in_app_purchase package
  }

  static Future<void> restorePurchases() async {
    // TODO: Implement restore logic
  }

  static Future<void> removeAds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ads_removed', true);
  }
}
