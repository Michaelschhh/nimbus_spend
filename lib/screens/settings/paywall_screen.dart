import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../services/iap_service.dart';
import '../../services/ad_service.dart';


class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sProv = context.watch<SettingsProvider>();
    final s = sProv.settings;

    IAPService.onPurchaseSuccess = (id) {
      if (id == 'remove_ads') {
        sProv.removeAds();
        _showThankYou(context, "Ad Removal");
      } else if (id == 'unlock_themes') {
        sProv.unlockThemes();
        _showThankYou(context, "Premium Themes");
      } else if (id == 'unlock_security') {
        sProv.unlockSecurity();
        _showThankYou(context, "Secure App Lock");
      } else if (id == 'bundle_pro') {
        sProv.upgradeToPro();
        _showThankYou(context, "Pro Bundle");
      }
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Premium Features", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (!s.isPro && !s.adsRemoved) 
              _buyCard(context, "Remove Ads", "Clean experience, no interruptions.", "\$1.00", LucideIcons.ban, () {
                IAPService.onPurchaseSuccess?.call('remove_ads');
              }),
            if (s.adsRemoved)
              _purchasedBadge("Ads Removed"),

            const SizedBox(height: 16),
            if (!s.themesUnlocked && !s.isPro)
              _buyCard(context, "Unlock Themes", "10 gorgeous premium themes.", "\$1.00", LucideIcons.palette, () {
                 IAPService.onPurchaseSuccess?.call('unlock_themes');
              }),
            if (s.themesUnlocked)
              _purchasedBadge("Themes Unlocked"),

            const SizedBox(height: 16),
            if (!s.isPro && !sProv.isSecurityUnlockedIAP())
              _buyCard(context, "Unlock Security", "Certified passcode & password protection.", "\$1.00", LucideIcons.shield, () {
                 IAPService.onPurchaseSuccess?.call('unlock_security');
              }),
            if (sProv.isSecurityUnlockedIAP())
              _purchasedBadge("Security Unlocked"),

            if (!s.isPro && (!s.adsRemoved || !sProv.isThemeUnlocked() || !sProv.isSecurityUnlockedIAP())) ...[
              const SizedBox(height: 30),
              Text("BEST VALUE", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              _buyCard(context, "Pro Bundle", "All features + Secure Lock + Mascot.", "\$2.50", LucideIcons.sparkles, () {
                 IAPService.onPurchaseSuccess?.call('bundle_pro');
              }, isFeatured: true),
            ],
            
            if (!sProv.isThemeUnlocked()) ...[
              const SizedBox(height: 16),
              _buyCard(context, "Watch Ad for 24h Themes", "Unlock all premium themes for 24 hours.", "FREE", LucideIcons.playCircle, () {
                AdService.showRewardedAd((reward) {
                  sProv.unlockThemeFor24h();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All themes unlocked for 24 hours! 🎨")));
                }, onAdSkipped: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ad not completed. Theme unlock failed.")));
                });
              }),
            ],

            
            if (s.isPro) ...[
              const SizedBox(height: 30),
              const Icon(LucideIcons.crown, color: Color(0xFFFFD700), size: 48),
              const SizedBox(height: 12),
              const Text("You are a Pro User", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Text("Thank you for your support!", style: TextStyle(color: AppColors.textDim)),
            ],

            const SizedBox(height: 40),
            const Text("THEMES GALLERY", style: TextStyle(color: AppColors.textDim, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            ...List.generate(10, (i) {
              final isLocked = !sProv.isThemeUnlocked() && i > 0;
              final selected = s.themeIndex == i;
              final isDark = Theme.of(context).brightness == Brightness.dark;

              return GestureDetector(
                onTap: () {
                  if (isLocked) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unlock themes below to use this!")));
                  } else {
                    sProv.setThemeIndex(i);
                  }
                },
                child: Container(

                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: selected ? Theme.of(context).primaryColor : (isDark ? Colors.white10 : Colors.black12), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 14, height: 14,
                        decoration: BoxDecoration(
                          color: _getThemePreviewColor(i), 
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: _getThemePreviewColor(i).withOpacity(0.3), blurRadius: 4)]
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(_getThemeName(i), style: TextStyle(fontSize: 15, fontWeight: selected ? FontWeight.bold : FontWeight.w500, letterSpacing: -0.2)),
                      ),
                      if (isLocked)
                        Icon(LucideIcons.lock, color: (isDark ? Colors.white24 : Colors.black26), size: 14)
                      else if (selected)
                        const Icon(LucideIcons.checkCircle, color: AppColors.success, size: 18)
                    ],
                  ),
                ),
              );
            }),
            
            if (s.themeExpiryTimestamp != null && !s.themesUnlocked && !s.isPro) ...[
              const SizedBox(height: 12),
              Text("Temporary Access Active: Ends in ${((s.themeExpiryTimestamp! - DateTime.now().millisecondsSinceEpoch) / 3600000).ceil()}h", style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
            ],

            
            const SizedBox(height: 40),
            TextButton(
              onPressed: () => IAPService.restorePurchases(),
              child: const Text("Restore Purchases", style: TextStyle(color: AppColors.textDim)),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showThankYou(BuildContext context, String product) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Purchase Successful! 🎉"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.heart, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text("Thank you for purchasing $product and supporting the Nimbus team!", textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Text("Here is Nimbus, our mascot, to show our gratitude. He'll accompany you throughout the app!", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textDim)),
            const SizedBox(height: 20),
            const Text("Tip: You can hide him in Settings if you need space.", style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Awesome")),
        ],
      ),
    );
  }

  Widget _buyCard(BuildContext context, String title, String desc, String price, IconData icon, VoidCallback onTap, {bool isFeatured = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isFeatured ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isFeatured ? Theme.of(context).primaryColor.withOpacity(0.5) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  Text(desc, style: const TextStyle(color: AppColors.textDim, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(12)),
              child: Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _purchasedBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _themesGrid(BuildContext context, int current, bool unlocked, SettingsProvider sProv) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6,
      ),
      itemCount: 10,
      itemBuilder: (context, i) {
        final isLocked = !unlocked && i > 0;
        final selected = current == i;
        return GestureDetector(
          onTap: isLocked ? null : () => sProv.setThemeIndex(i),
          child: Container(
            decoration: BoxDecoration(
              color: _getThemePreviewColor(i),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? Colors.white : Colors.transparent, width: 3),
              boxShadow: selected ? [BoxShadow(color: _getThemePreviewColor(i).withOpacity(0.5), blurRadius: 10)] : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(_getThemeName(i), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, shadows: [Shadow(color: Colors.black26, blurRadius: 4)])),
                ),
                if (isLocked)
                  const Positioned(top: 8, right: 8, child: Icon(LucideIcons.lock, color: Colors.white70, size: 14)),
                if (selected)
                  const Positioned(top: 8, left: 8, child: Icon(Icons.check_circle, color: Colors.white, size: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getThemePreviewColor(int i) {
    switch (i) {
      case 0: return const Color(0xFF0A84FF);
      case 1: return const Color(0xFF10BB7C);
      case 2: return const Color(0xFF2563EB);
      case 3: return const Color(0xFF64748B);
      case 4: return const Color(0xFFDB2777);
      case 5: return const Color(0xFF334155);
      case 6: return const Color(0xFFD97706);
      case 7: return const Color(0xFF059669);
      case 8: return const Color(0xFF7C3AED);
      case 9: return const Color(0xFFBE185D);
      default: return Colors.blue;
    }
  }

  String _getThemeName(int i) {
    switch (i) {
      case 0: return "Default";
      case 1: return "Emerald Night";
      case 2: return "Ocean Blue";
      case 3: return "Midnight Steel";
      case 4: return "Cherry Blossom";
      case 5: return "Obsidian";
      case 6: return "Sunburst";
      case 7: return "Forest";
      case 8: return "Lavender";
      case 9: return "Rose Gold";
      default: return "Unknown";
    }
  }
}
