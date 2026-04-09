import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/settings_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/bills_provider.dart';
import '../../providers/debt_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/common/currency_picker_modal.dart';
import '../../widgets/common/custom_switch.dart';
import '../../services/sound_service.dart';
import '../../services/iap_service.dart';
import '../../services/notification_service.dart';
import '../../services/export_service.dart';
import '../../providers/savings_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/shopping_provider.dart';
import '../../providers/account_provider.dart';
import '../../widgets/common/ad_placements.dart';
import '../../utils/responsive.dart';
import 'security_settings_screen.dart';
import 'salary_settings_screen.dart';
import 'paywall_screen.dart';
import '../../widgets/common/liquid_slider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SettingsProvider>();
    final s = prov.settings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(Responsive.sp(24, context)),
          children: [
            Text("Settings", style: TextStyle(fontSize: Responsive.fs(34, context), fontWeight: FontWeight.bold)),
            const BannerAdSpace(),
            const SizedBox(height: 15),
            
            _editCard(context, "Identity", s.name, LucideIcons.user, (v) => prov.updateProfile(v, s.monthlyBudget, s.hourlyWage, s.currency)),
            
            _allowanceTrackingCard(context, prov),

            if (s.hasMonthlyAllowance)
              _editCard(context, "Monthly Allocation", s.monthlyBudget.toStringAsFixed(0), LucideIcons.wallet, (v) => prov.updateProfile(s.name, double.tryParse(v) ?? 1000, s.hourlyWage, s.currency)),
            
            _editCard(context, "Available Resources", s.availableResources.toStringAsFixed(0), LucideIcons.landmark, (v) {
              final val = double.tryParse(v);
              if (val != null) prov.updateAvailableResources(val);
            }),
            
            if (s.hasMonthlyAllowance)
              _editCard(context, "Hourly Wage", s.hourlyWage.toStringAsFixed(0), LucideIcons.clock, (v) => prov.updateProfile(s.name, s.monthlyBudget, double.tryParse(v) ?? 20, s.currency)),
            
            if (s.hasMonthlyAllowance)
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const SalarySettingsScreen())),
                child: _staticCard(context, "Salary", s.isSalaryEarner ? "Active" : "Disabled", LucideIcons.briefcase),
              ),
            
            GestureDetector(
              onTap: () => _showCurrencyPicker(context, prov),
              child: _staticCard(context, "Standard Currency", s.currency, LucideIcons.globe),
            ),
            
            SizedBox(height: Responsive.sp(25, context)),
            Text("Preferences", style: TextStyle(color: AppColors.textDim, fontSize: Responsive.fs(13, context), fontWeight: FontWeight.bold)),
            SizedBox(height: Responsive.sp(10, context)),
            
            _sectionHeader("PREFERENCES"),
            _settingsCard(context, [
              _settingsRow(context, LucideIcons.palette, "Premium Features", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const PaywallScreen()))),
              _settingsRow(context, LucideIcons.shield, "Security Lock", () => Navigator.push(context, MaterialPageRoute(builder: (c) => SecuritySettingsScreen()))),
            ]),

            const SizedBox(height: 20),
            _notificationsCard(context),
            _soundCard(context, prov),
            _darkModeCard(context, prov),
            _performanceModeCard(context, prov),
            _motionBlurCard(context, prov),
            _environmentalEffectsCard(context, prov),


            // Nimbus Mascot toggle (Pro/adsRemoved only)
            if (s.isPro || s.adsRemoved) ...[
              _mascotCard(context, prov),
              if (s.mascotEnabled) _mascotTipsCard(context, prov),
            ],
            
            const SizedBox(height: 60),
            
            // Remove Ads
            if (!s.isPro && !s.adsRemoved)
              GestureDetector(
                onTap: () async {
                  await IAPService.buyRemoveAds();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Processing purchase...')));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Theme.of(context).primaryColor.withOpacity(0.2), Colors.purple.withOpacity(0.15)]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Icon(LucideIcons.shieldOff, color: Theme.of(context).primaryColor, size: 18),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text("Remove Ads", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                      Text(IAPService.priceString, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ])),
                    Icon(LucideIcons.chevronRight, color: Theme.of(context).primaryColor, size: 16),
                  ]),
                ),
              ),
            
            GestureDetector(
              onTap: () => IAPService.restorePurchases(),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [
                  Icon(LucideIcons.refreshCw, color: AppColors.textDim, size: 18),
                  SizedBox(width: 14),
                  Expanded(child: Text("Restore Purchases", style: TextStyle(fontSize: 15, color: AppColors.textDim))),
                ]),
              ),
            ),

            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final expenses = context.read<ExpenseProvider>().expenses;
                await ExportService.exportExpensesToCsv(context, expenses, prov);
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor, 
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12)),
                ),
                child: const Row(children: [
                  Icon(LucideIcons.downloadCloud, color: AppColors.success, size: 18),
                  SizedBox(width: 14),
                  Expanded(child: Text("Export Data (CSV)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                ]),
              ),
            ),

            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => _confirmPurge(context, prov),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: const Center(child: Text("PURGE ALL DATA", style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold))),
              ),
            ),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(title, style: const TextStyle(color: AppColors.textDim, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget _settingsCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(children: children),
    );
  }

  Widget _settingsRow(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(LucideIcons.chevronRight, color: AppColors.textDim, size: 16),
      onTap: onTap,
    );
  }

  void _showProfileEdit(BuildContext context, SettingsProvider prov) {
    final s = prov.settings;
    _editCard(context, "Identity", s.name, LucideIcons.user, (v) => prov.updateProfile(v, s.monthlyBudget, s.hourlyWage, s.currency));
  }

  void _showCurrencyPicker(BuildContext context, SettingsProvider prov) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => CurrencyPickerModal(onSelect: (code) {
        prov.completeOnboarding(prov.settings.name, prov.settings.monthlyBudget, prov.settings.hourlyWage, code);
        Navigator.pop(context);
      }),
    );
  }

  Widget _editCard(BuildContext context, String l, String v, IconData icon, Function(String) onSave) {
    return GestureDetector(
      onTap: () {
        final ctrl = TextEditingController(text: v);
        showDialog(context: context, builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text("Edit $l", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: const Text("Cancel", style: TextStyle(color: AppColors.textDim))
            ),
            TextButton(
              onPressed: () {
                onSave(ctrl.text);
                Navigator.pop(ctx);
              },
              child: Text("Save", style: TextStyle(color: Theme.of(context).primaryColor))
            )
          ]
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 18),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
            Text(v, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          ])),
          Icon(LucideIcons.edit3, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26), size: 16),
        ]),
      ),
    );
  }

  Widget _soundCard(BuildContext context, SettingsProvider prov) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(LucideIcons.volume2, color: Theme.of(context).primaryColor, size: 18),
        const SizedBox(width: 14),
        const Expanded(child: Text("App Sounds", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
        TextButton(
          onPressed: () => SoundService.tap(),
          child: const Text("TEST", style: TextStyle(color: AppColors.textDim, fontSize: 12)),
        ),
        const SizedBox(width: 10),
        CustomSwitch(
          value: prov.settings.soundsEnabled,
          onChanged: (val) async {
            await prov.setSoundsEnabled(val);
            SoundService.setEnabled(val);
          },
        ),
      ]),
    );
  }

  Widget _darkModeCard(BuildContext context, SettingsProvider prov) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(LucideIcons.moon, color: Theme.of(context).primaryColor, size: 18),
        const SizedBox(width: 14),
        const Expanded(child: Text("Dark Mode", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
        CustomSwitch(
          value: prov.settings.isDarkMode,
          onChanged: (val) {
            prov.setDarkMode(val);
          },
        ),
      ]),
    );
  }

  Widget _mascotCard(BuildContext context, SettingsProvider prov) {
    return GestureDetector(
      onTap: () => prov.setMascotEnabled(!prov.settings.mascotEnabled),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Icon(LucideIcons.cloud, color: Theme.of(context).primaryColor, size: 18),
          const SizedBox(width: 14),
          const Expanded(child: Text("Nimbus Mascot", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
          CustomSwitch(
            value: prov.settings.mascotEnabled,
            onChanged: (val) {
              prov.setMascotEnabled(val);
            },
          ),
        ]),
      ),
    );
  }

  Widget _mascotTipsCard(BuildContext context, SettingsProvider prov) {
    return GestureDetector(
      onTap: () => prov.setMascotTipsEnabled(!prov.settings.mascotTipsEnabled),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Icon(LucideIcons.messageCircle, color: Theme.of(context).primaryColor, size: 18),
          const SizedBox(width: 14),
          const Expanded(child: Text("Nimbus Finance Tips", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
          CustomSwitch(
            value: prov.settings.mascotTipsEnabled,
            onChanged: (val) {
              prov.setMascotTipsEnabled(val);
            },
          ),
        ]),
      ),
    );
  }

  Widget _staticCard(BuildContext context, String l, String v, IconData i) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(i, color: Theme.of(context).primaryColor, size: 18),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
          Text(v, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.success)),
        ])),
        Icon(LucideIcons.chevronRight, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26), size: 16),
      ]),
    );
  }

  void _confirmPurge(BuildContext context, SettingsProvider prov) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      title: const Text("Purge Data"),
      content: const Text("Wiping all financial data. App will reset."),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
        TextButton(onPressed: () { 
          prov.clearAllData(); 
          context.read<ExpenseProvider>().clear();
          context.read<BillsProvider>().clear();
          context.read<DebtProvider>().clear();
          context.read<GoalsProvider>().clear();
          context.read<SubscriptionProvider>().clear();
          context.read<SavingsProvider>().clear();
          context.read<IncomeProvider>().clear();
          context.read<ShoppingProvider>().clear();
          context.read<AccountProvider>().clear();
          Navigator.pop(ctx); 
        }, child: const Text("PURGE", style: TextStyle(color: AppColors.danger))),
      ],
    ));
  }

  String _getThemeName(int index) {
    switch(index) {
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
      default: return "Default";
    }
  }

  Widget _performanceModeCard(BuildContext context, SettingsProvider prov) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(LucideIcons.zap, color: Theme.of(context).primaryColor, size: 18),
        const SizedBox(width: 14),
        const Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Performance Mode", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            Text("Optimizes for lower-end devices", style: TextStyle(color: AppColors.textDim, fontSize: 11)),
          ],
        )),
        CustomSwitch(
          value: prov.settings.performanceModeEnabled,
          onChanged: (val) {
            prov.setPerformanceMode(val);
          },
        ),
      ]),
    );
  }

  Widget _motionBlurCard(BuildContext context, SettingsProvider prov) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(LucideIcons.wind, color: Theme.of(context).primaryColor, size: 18),
        const SizedBox(width: 14),
        const Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Motion Blur", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            Text("Smooth UI transitions", style: TextStyle(color: AppColors.textDim, fontSize: 11)),
          ],
        )),
        CustomSwitch(
          value: prov.settings.motionBlurEnabled,
          onChanged: (val) {
            prov.setMotionBlur(val);
          },
        ),
      ]),
    );
  }

  Widget _notificationsCard(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await NotificationService.requestPermission();
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification permissions requested.')));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          Icon(LucideIcons.bell, color: Theme.of(context).primaryColor, size: 18),
          const SizedBox(width: 14),
          const Expanded(child: Text("Enable Notifications", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
          Icon(LucideIcons.chevronRight, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26), size: 16),
        ]),
      ),
    );
  }

  Widget _allowanceTrackingCard(BuildContext context, SettingsProvider prov) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(LucideIcons.calendarCheck, color: Theme.of(context).primaryColor, size: 18),
        const SizedBox(width: 14),
        const Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Monthly Allowance", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            Text("Enable budgeting & salary features", style: TextStyle(color: AppColors.textDim, fontSize: 11)),
          ],
        )),
        CustomSwitch(
          value: prov.settings.hasMonthlyAllowance,
          onChanged: (val) {
            prov.toggleMonthlyAllowance(val);
          },
        ),
      ]),
    );
  }

  Widget _environmentalEffectsCard(BuildContext context, SettingsProvider prov) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(children: [
            Icon(LucideIcons.droplets, color: Theme.of(context).primaryColor, size: 18),
            const SizedBox(width: 14),
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Liquid Glass Overlay", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                Text("System-wide fluid physics and rendering", style: TextStyle(color: AppColors.textDim, fontSize: 11)),
              ],
            )),
            CustomSwitch(
              value: prov.settings.liquidEffectEnabled,
              onChanged: (val) {
                if (!prov.settings.isPro) {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const PaywallScreen()));
                  return;
                }
                prov.setLiquidEffectEnabled(val);
              },
            ),
          ]),
          if (prov.settings.liquidEffectEnabled && prov.settings.isPro) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 8),
                const Text("Blur Intensity", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Expanded(
                  child: LiquidSlider(
                    value: prov.settings.blurIntensity,
                    min: 0.0,
                    max: 0.5,
                    onChanged: (v) => prov.setLiquidIntensities(v, prov.settings.refractionIntensity),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 8),
                const Text("Dispersion", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Expanded(
                  child: LiquidSlider(
                    value: prov.settings.refractionIntensity,
                    min: 0.0,
                    max: 0.15,
                    onChanged: (v) => prov.setLiquidIntensities(prov.settings.blurIntensity, v),
                  ),
                ),
              ],
            ),
          ]
          else if (!prov.settings.isPro) ...[
             const SizedBox(height: 10),
             Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
               child: const Row(
                 children: [
                   Icon(LucideIcons.lock, size: 14, color: Colors.amber),
                   SizedBox(width: 8),
                   Text("Pro feature", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                 ],
               ),
             )
          ]
        ],
      ),
    );
  }
}