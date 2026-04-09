import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../theme/colors.dart';
import '../../services/shader_service.dart';
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
import '../../widgets/common/calculator_widget.dart';
import '../../utils/responsive.dart';
import '../../widgets/forms/add_income_form.dart';
import '../shopping/shopping_lists_screen.dart';
import '../../providers/shopping_provider.dart';
import '../../widgets/common/account_management_sheet.dart';
import '../income/income_screen.dart';

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
    final shopProv = context.watch<ShoppingProvider>();

    return Scaffold(
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Responsive.sp(24, context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Responsive.sp(20, context)),
              Text("Finances",
                  style: TextStyle(fontSize: Responsive.fs(34, context), fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), letterSpacing: -1)),
              const BannerAdSpace(),
              const SizedBox(height: 20),

              Text("Quick Actions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDim)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _quickAction(
                      context,
                      icon: LucideIcons.calculator,
                      label: "Calculator",
                      onTap: () => showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "Calculator",
                        barrierColor: Colors.black.withOpacity(0.5),
                        transitionDuration: const Duration(milliseconds: 600), // Half current speed (standard is 300ms)
                        pageBuilder: (ctx, anim1, anim2) => const Align(
                          alignment: Alignment.bottomCenter,
                          child: CalculatorWidget(),
                        ),
                        transitionBuilder: (ctx, anim, anim2, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                            child: child,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _quickAction(
                      context,
                      icon: LucideIcons.trendingUp,
                      label: "Log Income",
                      onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => const AddIncomeForm()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _quickAction(
                      context,
                      icon: LucideIcons.users,
                      label: "Portfolios",
                      onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => const AccountManagementBottomSheet()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Smart Net Worth Summary
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Responsive.sp(24, context)),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("AVAILABLE RESOURCES", 
                        style: TextStyle(color: AppColors.textDim, fontSize: Responsive.fs(10, context), fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    SizedBox(height: Responsive.sp(8, context)),
                    Text(Formatters.currency(s.availableResources, s.currency),
                        style: TextStyle(fontSize: Responsive.fs(38, context), fontWeight: FontWeight.w700, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), letterSpacing: -2)),
                    SizedBox(height: Responsive.sp(12, context)),
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
              SizedBox(height: Responsive.sp(35, context)),

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
                color: Theme.of(context).primaryColor,
                screen: const SubscriptionsScreen(),
              ),
              _glassCard(
                context,
                icon: LucideIcons.shoppingBag,
                title: "Shopping Lists",
                subtitle: "${shopProv.lists.where((l) => !l.isCompleted).length} active lists",
                color: Colors.orange,
                screen: const ShoppingListsScreen(),
              ),
              _glassCard(
                context,
                icon: LucideIcons.banknote,
                title: "Income Ledger",
                subtitle: "Manage logged incomes",
                color: AppColors.success,
                screen: const IncomeScreen(),
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
    final sProv = context.watch<SettingsProvider>();
    final isWater = sProv.settings.themeIndex == 10;
    
    final filter = isWater 
        ? (ShaderService.getLiquidGlassFilter(intensity: 0.05, blurAmt: sProv.settings.blurIntensity * 30.0) ?? ImageFilter.blur(sigmaX: 8, sigmaY: 8))
        : ImageFilter.blur(sigmaX: 8, sigmaY: 8);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: filter,
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

  Widget _quickAction(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    final sProv = context.watch<SettingsProvider>();
    final isWater = sProv.settings.themeIndex == 10;

    Widget card = Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isWater ? (Theme.of(context).brightness == Brightness.dark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2)) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isWater ? Colors.white.withOpacity(0.1) : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );

    if (isWater) {
      final filter = ShaderService.getLiquidGlassFilter(intensity: 0.05, blurAmt: sProv.settings.blurIntensity * 30.0);
      card = ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: filter != null ? BackdropFilter(filter: filter, child: card) : card,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}
