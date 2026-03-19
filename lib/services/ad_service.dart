import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer';

class AdService {
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static bool _isAdLoaded = false;
  static bool _isRewardedAdLoaded = false;

  // Ad Unit IDs
  static String get interstitialAdUnitId => 
    const bool.fromEnvironment('dart.vm.product') 
      ? 'ca-app-pub-1530144408092330/9449178515' 
      : 'ca-app-pub-3940256099942544/1033173712'; // Test ID

  static String get bannerAdUnitId => 
    const bool.fromEnvironment('dart.vm.product') 
      ? 'ca-app-pub-1530144408092330/8537432429' 
      : 'ca-app-pub-3940256099942544/6300978111'; // Test ID

  static String get rewardedAdUnitId => 
    const bool.fromEnvironment('dart.vm.product') 
      ? 'ca-app-pub-1530144408092330/3587150193' 
      : 'ca-app-pub-3940256099942544/5224354917'; // Test ID

  static Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadInterstitialAd();
    _loadRewardedAd();
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

  static void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          log("Rewarded Ad Loaded Successfully");
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          log("Rewarded Ad Failed to Load: $error");
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

  static void showRewardedAd(Function(RewardItem) onRewardEarned, {Function()? onAdSkipped}) {
    if (_rewardedAd != null && _isRewardedAdLoaded) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isRewardedAdLoaded = false;
          _loadRewardedAd();
          if (onAdSkipped != null) onAdSkipped();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isRewardedAdLoaded = false;
          _loadRewardedAd();
          if (onAdSkipped != null) onAdSkipped();
        },
      );

      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        onRewardEarned(reward);
      });
    } else {
      log("Rewarded Ad not ready yet");
      if (onAdSkipped != null) onAdSkipped();
      _loadRewardedAd();
    }
  }
}
