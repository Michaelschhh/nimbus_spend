import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../providers/settings_provider.dart';
import '../../providers/savings_provider.dart';
import '../../providers/bills_provider.dart';
import '../../providers/debt_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/subscription_provider.dart';
import '../savings/savings_screen.dart';
import '../bills/bills_screen.dart';
import '../debts/debts_screen.dart';
import '../goals/goals_screen.dart';
import '../subscriptions/subscriptions_screen.dart';
import '../../widgets/common/ad_placements.dart';

class FinancialHubScreen extends StatelessWidget {
  const FinancialHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sProv = context.watch<SettingsProvider>();
    final s = sProv.settings;
    final savProv = context.watch<SavingsProvider>();
    final billProv = context.watch<BillsProvider>();
    final debtProv = context.watch<DebtProvider>();
    final goalProv = context.watch<GoalsProvider>();
    final subProv = context.watch<SubscriptionProvider>();

    return Scaffold(
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text("Finances",
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), letterSpacing: -1)),
              const BannerAdSpace(),
              const SizedBox(height: 20),

              // Smart Net Worth Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("AVAILABLE RESOURCES", 
                        style: TextStyle(color: AppColors.textDim, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Text(Formatters.currency(s.availableResources, s.currency),
                        style: TextStyle(fontSize: 38, fontWeight: FontWeight.w700, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), letterSpacing: -2)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text("+${Formatters.currency(savProv.totalSavings, s.currency)} saved", 
                              style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        if (billProv.totalUnpaid > 0 || (debtProv.totalIOwe - debtProv.totalOwedToMe) > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text("-${Formatters.currency(billProv.totalUnpaid + (debtProv.totalIOwe - debtProv.totalOwedToMe > 0 ? debtProv.totalIOwe - debtProv.totalOwedToMe : 0), s.currency)} owed", 
                                style: const TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              _glassCard(
                context,
                icon: LucideIcons.piggyBank,
                title: "Savings Vault",
                subtitle: Formatters.currency(savProv.totalSavings, s.currency),
                color: AppColors.success,
                screen: const SavingsScreen(),
              ),
              _glassCard(
                context,
                icon: LucideIcons.fileText,
                title: "Bills",
                subtitle: "${billProv.bills.where((b) => !b.isPaid).length} unpaid • ${Formatters.currency(billProv.totalUnpaid, s.currency)}",
                color: AppColors.warning,
                screen: const BillsScreen(),
              ),
              _glassCard(
                context,
                icon: LucideIcons.arrowLeftRight,
                title: "Debts",
                subtitle: "Owe ${Formatters.currency(debtProv.totalIOwe, s.currency)} • Owed ${Formatters.currency(debtProv.totalOwedToMe, s.currency)}",
                color: AppColors.danger,
                screen: const DebtsScreen(),
              ),
              _glassCard(
                context,
                icon: LucideIcons.target,
                title: "Goals",
                subtitle: "${goalProv.activeGoals.length} active • ${goalProv.completedGoals.length} achieved",
                color: AppColors.lifeColor,
                screen: const GoalsScreen(),
              ),
              _glassCard(
                context,
                icon: LucideIcons.refreshCw,
                title: "Subscriptions",
                subtitle: "${Formatters.currency(subProv.monthlySubCost, s.currency)}/mo • ${subProv.subscriptions.where((s) => s.isActive).length} active",
                color: AppColors.primary,
                screen: const SubscriptionsScreen(),
              ),

              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(subtitle,
                            style: TextStyle(color: color.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Icon(LucideIcons.chevronRight, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.2), size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
