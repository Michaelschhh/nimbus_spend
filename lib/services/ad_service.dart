import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer';

class AdService {
  static InterstitialAd? _interstitialAd;
  static bool _isAdLoaded = false;

  // Ad Unit IDs
  static String get interstitialAdUnitId => 
    const bool.fromEnvironment('dart.vm.product') 
      ? 'ca-app-pub-1530144408092330/9449178515' 
      : 'ca-app-pub-3940256099942544/1033173712'; // Test ID

  static String get bannerAdUnitId => 
    const bool.fromEnvironment('dart.vm.product') 
      ? 'ca-app-pub-1530144408092330/8537432429' 
      : 'ca-app-pub-3940256099942544/6300978111'; // Test ID

  static Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
  }

  static void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          log("Interstitial Ad Loaded Successfully");
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          log("Interstitial Ad Failed to Load: $error");
        },
      ),
    );
  }

  static void showInterstitialAd(Function onComplete) {
    if (_interstitialAd != null && _isAdLoaded) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAdLoaded = false;
          _loadInterstitialAd(); // Preload next one
          onComplete(); // Continue logic after ad plays
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isAdLoaded = false;
          _loadInterstitialAd();
          onComplete(); // Fail gracefully
        },
      );

      _interstitialAd!.show();
    } else {
      // If ad isn't ready, let them through anyway so they don't get stuck
      log("Interstitial Ad not ready yet, skipping...");
      onComplete();
      _loadInterstitialAd();
    }
  }
}
