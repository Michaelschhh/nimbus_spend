import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer';

class AdService {
  static RewardedAd? _rewardedAd;
  static bool _isAdLoaded = false;

  // TODO: Replace with real ID from AdMob before Play Store
  static const String rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  static Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadRewardedAd();
  }

  static void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          log("Ad Loaded Successfully");
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          log("Ad Failed to Load: $error");
        },
      ),
    );
  }

  static void showRewardedAd(Function onRewardEarned) {
    if (_rewardedAd != null && _isAdLoaded) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAdLoaded = false;
          _loadRewardedAd(); // Preload next one
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isAdLoaded = false;
          _loadRewardedAd();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onRewardEarned();
        },
      );
    } else {
      // If ad isn't ready, let them through anyway so they don't get stuck
      // but try to load for next time.
      log("Ad not ready yet, skipping gate...");
      onRewardEarned();
      _loadRewardedAd();
    }
  }
}
