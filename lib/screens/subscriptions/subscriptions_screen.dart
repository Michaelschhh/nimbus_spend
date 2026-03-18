import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../providers/subscription_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/subscription.dart';
import '../../utils/formatters.dart';
import '../../theme/colors.dart';
import '../../widgets/forms/add_subscription_form.dart';
import '../../widgets/common/apple_button.dart';
import '../../services/sound_service.dart';
import '../../widgets/common/ad_placements.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});
  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SubscriptionProvider>().fetchSubscriptions());
  }

  @override
  Widget build(BuildContext context) {
    final subProv = context.watch<SubscriptionProvider>();
    final s = context.read<SettingsProvider>().settings;
    final active = subProv.subscriptions.where((s) => s.isActive).toList();
    final paused = subProv.subscriptions.where((s) => !s.isActive).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                const Text("Subscriptions", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1)),
                const Spacer(),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                    builder: (_) => const AddSubscriptionForm(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: AppColors.cardBg, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.plus, color: AppColors.primary, size: 20),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Text("${Formatters.currency(subProv.monthlySubCost, s.currency)}/mo • ${active.length} active",
                  style: const TextStyle(color: AppColors.textDim, fontSize: 14)),
              const BannerAdSpace(),
              // Monthly cost card
              const SizedBox(height: 25),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.cardBg, borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("MONTHLY BURN", style: TextStyle(color: AppColors.textDim, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Text(Formatters.currency(subProv.monthlySubCost, s.currency),
                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -2)),
                  const SizedBox(height: 8),
                  if (s.monthlyBudget > 0)
                    Text("${(subProv.monthlySubCost / s.monthlyBudget * 100).toStringAsFixed(1)}% of your monthly allowance",
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                ]),
              ),
              const SizedBox(height: 30),

              if (subProv.subscriptions.isEmpty)
                _emptyState()
              else ...[
                if (active.isNotEmpty) ...[
                  const Text("ACTIVE", style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  ...active.map((sub) => _subCard(context, sub, s.currency, subProv)),
                  const SizedBox(height: 25),
                ],
                if (paused.isNotEmpty) ...[
                  const Text("PAUSED", style: TextStyle(color: AppColors.textDim, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  ...paused.map((sub) => _subCard(context, sub, s.currency, subProv)),
                ],
              ],
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(children: [
          Icon(LucideIcons.refreshCw, color: Colors.white.withOpacity(0.1), size: 48),
          const SizedBox(height: 16),
          const Text("No subscriptions yet", style: TextStyle(color: AppColors.textDim)),
        ]),
      ),
    );
  }

  Widget _subCard(BuildContext context, Subscription sub, String cur, SubscriptionProvider prov) {
    return GestureDetector(
      onTap: () => _showBlurMenu(context, sub, prov),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: sub.isActive ? AppColors.primary.withOpacity(0.08) : Colors.white.withOpacity(0.04)),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (sub.isActive ? AppColors.primary : AppColors.textDim).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.refreshCw,
                color: sub.isActive ? AppColors.primary : AppColors.textDim, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(sub.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            Text("${sub.frequency} • Next: ${DateFormat('MMM dd').format(sub.nextDueDate)}${sub.billingDay != null ? ' (Day ${sub.billingDay})' : ''}",
                style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(Formatters.currency(sub.amount, cur),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            if (!sub.isActive)
              const Text("Paused", style: TextStyle(color: AppColors.textDim, fontSize: 10)),
          ]),
        ]),
      ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  void _showBlurMenu(BuildContext context, Subscription sub, SubscriptionProvider prov) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "SubOptions",
      pageBuilder: (ctx, a1, a2) => Material(
        type: MaterialType.transparency,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBg, borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(sub.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 6),
                Text(sub.frequency, style: const TextStyle(color: AppColors.textDim, fontSize: 14)),
                const SizedBox(height: 30),
                AppleButton(
                  label: sub.isActive ? "Pause Subscription" : "Resume Subscription",
                  bgColor: sub.isActive ? AppColors.warning : AppColors.success,
                  textColor: Colors.white,
                  onTap: () {
                    prov.toggleSubscription(sub);
                    SoundService.success();
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 12),
                AppleButton(label: "Edit", onTap: () {
                  Navigator.pop(ctx);
                  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddSubscriptionForm(existingSubscription: sub));
                }),
                const SizedBox(height: 12),
                AppleButton(label: "Delete", isDestructive: true, onTap: () {
                  prov.deleteSubscription(sub.id);
                  SoundService.delete();
                  Navigator.pop(ctx);
                }),
                const SizedBox(height: 12),
                AppleButton(label: "Cancel", bgColor: Colors.white10, textColor: Colors.white, onTap: () => Navigator.pop(ctx)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
