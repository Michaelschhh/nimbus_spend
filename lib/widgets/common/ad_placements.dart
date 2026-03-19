import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/ad_service.dart';
import '../../providers/settings_provider.dart';

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
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
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
    final s = context.watch<SettingsProvider>().settings;
    if (s.adsRemoved || s.isPro) return const SizedBox.shrink();
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
    final s = context.watch<SettingsProvider>().settings;
    if (s.adsRemoved || s.isPro) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40, 
                decoration: BoxDecoration(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12), borderRadius: BorderRadius.circular(8)),
                child: Icon(LucideIcons.image, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sponsored Content", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
                  const Text("Ad", style: TextStyle(color: AppColors.textDim, fontSize: 10)),
                ]
              )
            ],
          ),
          const SizedBox(height: 12),
          Text("[ Native Ad Space ] - Placed natively in lists.", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54))),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text("Learn More", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
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
          gradient: LinearGradient(colors: [Colors.purple.shade700, Theme.of(context).primaryColor]),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 5))]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.video, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
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
            Icon(LucideIcons.monitorPlay, color: Theme.of(context).primaryColor, size: 64),
            const SizedBox(height: 20),
            Text("[ App Open Ad Space ]", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            CircularProgressIndicator(color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            Text("Loading your financial future...", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87))),
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
