import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/sound_service.dart';
import '../../services/ad_service.dart';

class BannerAdSpace extends StatefulWidget {
  const BannerAdSpace({super.key});

  @override
  State<BannerAdSpace> createState() => _BannerAdSpaceState();
}

class _BannerAdSpaceState extends State<BannerAdSpace> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _loadAd();
    }
  }

  void _loadAd() {
    final width = MediaQuery.of(context).size.width.truncate();
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize(width: width, height: 50),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

class NativeAdSpace extends StatelessWidget {
  const NativeAdSpace({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40, 
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: const Icon(LucideIcons.image, color: Colors.white54, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sponsored Content", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("Ad", style: TextStyle(color: AppColors.textDim, fontSize: 10)),
                ]
              )
            ],
          ),
          const SizedBox(height: 12),
          const Text("[ Native Ad Space ] - Placed natively in lists.", style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: const Text("Learn More", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

class VideoRewardedAdButton extends StatelessWidget {
  final VoidCallback onWatch;
  final String label;

  const VideoRewardedAdButton({super.key, required this.onWatch, this.label = "Watch Video Ad for Reward"});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onWatch,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.purple.shade700, AppColors.primary]),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.video, color: Colors.white),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class AppOpenAdSimulation extends StatelessWidget {
  const AppOpenAdSimulation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.monitorPlay, color: AppColors.primary, size: 64),
            const SizedBox(height: 20),
            const Text("[ App Open Ad Space ]", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            const Text("Loading your financial future...", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Skip Ad", style: TextStyle(color: Colors.white38))
            )
          ],
        ),
      ),
    );
  }
}
