import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';

import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../utils/life_cost_utils.dart';
import '../../widgets/forms/add_expense_form.dart';
import '../../widgets/common/apple_button.dart';
import '../../widgets/common/ad_placements.dart';
import '../../services/sound_service.dart';
import '../../services/local_ai_service.dart';
import '../../models/expense.dart';
import '../../utils/responsive.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exp = context.watch<ExpenseProvider>();
    final sProv = context.watch<SettingsProvider>();
    final s = sProv.settings;
    
    double left = s.monthlyBudget - exp.totalSpentThisMonth;
    bool isOver = left < 0;

    return Scaffold(
      
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.sp(24, context)),
                child: _header(context, s.name, s.availableResources, s.currency),
              ),
              SizedBox(height: Responsive.sp(10, context)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.sp(24, context)),
                child: const BannerAdSpace(),
              ),
              SizedBox(height: Responsive.sp(10, context)),

              // THE MAIN ALLOWANCE CARD
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.sp(24, context)),
                child: _mainCard(context, left, s.currency, isOver),
              ),
              SizedBox(height: Responsive.sp(30, context)),

              // AI INSIGHTS SECTION
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.sp(24, context)),
                child: Text("AI Insights", style: TextStyle(fontSize: Responsive.fs(22, context), fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), letterSpacing: -0.5)),
              ),
              SizedBox(height: Responsive.sp(15, context)),
              _buildInsightsCarousel(context, exp.expenses, s.monthlyBudget, s.hourlyWage, exp.totalSpentThisMonth),
              
              SizedBox(height: Responsive.sp(30, context)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.sp(24, context)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Transactions", style: TextStyle(fontSize: Responsive.fs(22, context), fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), letterSpacing: -0.5)),
                    if (exp.hiddenExpenses.isNotEmpty)
                      GestureDetector(
                        onTap: () => _showHiddenTransactions(context, exp, sProv, s.currency),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(LucideIcons.eyeOff, size: 14, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 6),
                            Text("${exp.hiddenExpenses.length} Hidden", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.sp(15, context)),
              
              if (exp.visibleExpenses.isEmpty)
                Center(child: Padding(padding: EdgeInsets.all(Responsive.sp(40, context)), child: Text("Wallet Empty", style: const TextStyle(color: AppColors.textDim))))
              else
                ..._buildCategoryGroups(context, exp, sProv, s.currency),
              
              SizedBox(height: Responsive.sp(140, context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String name, double resource, String cur) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sProv = context.read<SettingsProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Available Resources", style: TextStyle(color: AppColors.textDim, fontSize: Responsive.fs(13, context), fontWeight: FontWeight.bold)),
          Text(Formatters.currency(resource, cur), style: TextStyle(fontSize: Responsive.fs(32, context), fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, letterSpacing: -1)),
        ]),
        Row(children: [
          GestureDetector(
            onTap: () => sProv.setDarkMode(!isDark),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
              ),
              child: Icon(isDark ? LucideIcons.moon : LucideIcons.sun, size: 18, color: isDark ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(backgroundColor: Theme.of(context).cardColor, child: Text(name.isNotEmpty ? name[0] : "U", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
        ]),
      ],
    );
  }

  Widget _mainCard(BuildContext context, double left, String cur, bool isOver) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isOver ? AppColors.danger.withOpacity(0.5) : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("MONTHLY ALLOWANCE", style: TextStyle(color: isOver ? AppColors.danger : AppColors.textDim, fontSize: Responsive.fs(10, context), fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          GestureDetector(
            onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => const AddExpenseForm()),
            child: Icon(LucideIcons.plusCircle, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), size: Responsive.sp(28, context)),
          ),
        ]),
        SizedBox(height: Responsive.sp(12, context)),
        Text(Formatters.currency(left, cur), 
          style: TextStyle(fontSize: Responsive.fs(46, context), fontWeight: FontWeight.w700, color: isOver ? AppColors.danger : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), letterSpacing: -2)),
        SizedBox(height: Responsive.sp(15, context)),
        Text(isOver ? "DANGER: Budget Exceeded" : "Current Cycle Active", 
          style: TextStyle(color: isOver ? AppColors.danger : AppColors.success, fontWeight: FontWeight.bold, fontSize: Responsive.fs(11, context))),
      ]),
    );
  }

  Widget _item(BuildContext context, dynamic e, ExpenseProvider prov, SettingsProvider sProv, String cur, {bool isHidden = false}) {
    final item = InkWell(
      onTap: null,
      onLongPress: () => _showAppleMenu(context, e, prov, sProv, isFromHidden: isHidden),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.note.isNotEmpty ? e.note : e.category, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.w500, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (sProv.settings.hourlyWage > 0 && e.lifeCostHours != null && e.lifeCostHours > 0)
                Text("${e.lifeCostHours.toStringAsFixed(1)}h of life", style: const TextStyle(color: AppColors.lifeColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ]
          )),
          Text(Formatters.currency(e.amount, cur), style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold, fontSize: 14)),
          if (isHidden) ...[
            const SizedBox(width: 8),
            Icon(LucideIcons.undo2, size: 14, color: Theme.of(context).primaryColor),
          ],
        ]),
      ),
    );
    
    if (sProv.settings.performanceModeEnabled) return item;
    return item.animate().fadeIn(duration: 300.ms, curve: Curves.easeOut);
  }




  List<Widget> _buildCategoryGroups(BuildContext context, ExpenseProvider exp, SettingsProvider sProv, String cur) {
    final visible = exp.visibleExpenses;
    // Group by category
    final Map<String, List<dynamic>> groups = {};
    for (var e in visible) {
      groups.putIfAbsent(e.category, () => []).add(e);
    }

    return groups.entries.map((entry) {
      final category = entry.key;
      final items = entry.value;
      final total = items.fold<double>(0, (sum, e) => sum + e.amount);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Theme(

              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                leading: Icon(_getCategoryIcon(category), color: Theme.of(context).primaryColor, size: 20),
                title: Text(category, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text("${items.length} transaction${items.length > 1 ? 's' : ''} · ${Formatters.currency(total, cur)}",
                  style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
                iconColor: (Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54),
                collapsedIconColor: (Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54),
                children: items.map<Widget>((e) => _item(context, e, exp, sProv, cur)).toList(),
              ),
            ),
          ),
        );
    }).toList();


  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Shopping': return LucideIcons.shoppingBag;
      case 'Food': return LucideIcons.utensils;
      case 'Transport': return LucideIcons.car;
      case 'Bills': return LucideIcons.fileText;
      case 'Health': return LucideIcons.heart;
      default:
        if (category.contains('Bills')) return LucideIcons.fileText;
        if (category.contains('Debt')) return LucideIcons.creditCard;
        if (category.contains('Savings')) return LucideIcons.piggyBank;
        if (category.contains('Goals')) return LucideIcons.target;
        if (category.contains('Subscription')) return LucideIcons.repeat;
        return LucideIcons.receipt;
    }
  }

  void _showAppleMenu(BuildContext context, dynamic e, ExpenseProvider prov, SettingsProvider sProv, {bool isFromHidden = false}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      pageBuilder: (ctx, anim1, anim2) => Material(
        type: MaterialType.transparency,
        child: sProv.settings.performanceModeEnabled 
          ? Center(child: _menuContent(ctx, e, prov, sProv, isFromHidden))
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Center(child: _menuContent(ctx, e, prov, sProv, isFromHidden)),
            ),
      ),
    );
  }

  Widget _menuContent(BuildContext context, dynamic e, ExpenseProvider prov, SettingsProvider sProv, bool isFromHidden) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(32), border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(e.category, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          if (!isFromHidden && e.category != 'Bills 📄' && e.category != 'Debts 💳' && e.category != 'Goals 🎯' && e.category != 'Savings 💰') ...[
            AppleButton(label: "Edit Entry", onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddExpenseForm(existingExpense: e));
            }),
            const SizedBox(height: 12),
          ],
          AppleButton(
            label: isFromHidden ? "Unhide Transaction" : "Hide Transaction", 
            onTap: () {
              if (isFromHidden) {
                Navigator.pop(context);
                _showUnhideConfirmation(context, e, prov);
              } else {
                prov.hideTransaction(e.id);
                Navigator.pop(context);
              }
            }
          ),
          const SizedBox(height: 12),
          if (e.category != 'Bills 📄' && e.category != 'Debts 💳' && e.category != 'Goals 🎯' && e.category != 'Savings 💰' && e.category != 'Subscriptions 💎')
            AppleButton(label: "Delete Payment", isDestructive: true, onTap: () {
              prov.deleteExpense(e.id, sProv);
              SoundService.delete();
              Navigator.pop(context);
            }),
          const SizedBox(height: 12),
            AppleButton(label: "Cancel", bgColor: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12), textColor: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }


  void _showUnhideConfirmation(BuildContext context, dynamic e, ExpenseProvider prov) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Restore Transaction?"),
        content: Text("Do you want to move this from hidden back to your main transactions?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              prov.unhideTransaction(e.id);
              Navigator.pop(ctx);
            }, 
            child: Text("Restore", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }


  void _showHiddenTransactions(BuildContext context, ExpenseProvider exp, SettingsProvider sProv, String cur) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        ),
        child: Column(
          children: [
            Container(height: 5, width: 40, decoration: BoxDecoration(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Row(children: [
              Icon(LucideIcons.eyeOff, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 10),
              Text("Hidden Transactions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
            ]),
            const SizedBox(height: 8),
            Text("Long-press any item to restore it", style: TextStyle(color: AppColors.textDim, fontSize: 12)),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<ExpenseProvider>(
                builder: (context, prov, child) {
                  return prov.hiddenExpenses.isEmpty
                    ? Center(child: Text("No hidden transactions", style: TextStyle(color: AppColors.textDim)))
                    : ListView.builder(
                        itemCount: prov.hiddenExpenses.length,
                        itemBuilder: (context, index) {
                          final e = prov.hiddenExpenses[index];
                          return _item(context, e, prov, sProv, cur, isHidden: true);
                        },
                      );
                }
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCarousel(BuildContext context, List<dynamic> expenses, double budget, double wage, double totalSpentThisMonth) {
    // Cast list back for service
    final eList = expenses.cast<Expense>();
    final insights = LocalAIService.generateInsights(eList, budget, wage, totalSpentThisMonth);

    return SizedBox(
      height: 110,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          scrollDirection: Axis.horizontal,
          itemCount: insights.length,
          itemBuilder: (context, index) {
            final isWarning = insights[index].contains('⚠️') || insights[index].contains('Cost') || insights[index].contains('hours');
            return Container(
              width: 280,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isWarning ? AppColors.warning.withOpacity(0.3) : Theme.of(context).primaryColor.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [
                    Icon(LucideIcons.sparkles, color: isWarning ? AppColors.warning : Theme.of(context).primaryColor, size: 14),
                    const SizedBox(width: 8),
                    Text("NIMBUS AI", style: TextStyle(color: isWarning ? AppColors.warning : Theme.of(context).primaryColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ]),
                  const SizedBox(height: 10),
                  Text(insights[index], style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontSize: 13, height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}