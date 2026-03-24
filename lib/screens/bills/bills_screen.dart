import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../providers/bills_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/bill.dart';
import '../../models/expense.dart';
import '../../utils/life_cost_utils.dart';
import '../../utils/formatters.dart';
import '../../theme/colors.dart';
import '../../widgets/forms/add_bill_form.dart';
import '../../widgets/common/apple_button.dart';
import '../../services/sound_service.dart';
import '../../widgets/common/ad_placements.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});
  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BillsProvider>().fetchBills());
  }

  @override
  Widget build(BuildContext context) {
    final billProv = context.watch<BillsProvider>();
    final s = context.read<SettingsProvider>().settings;
    final unpaid = billProv.bills.where((b) => !b.isPaid).toList();
    final paid = billProv.bills.where((b) => b.isPaid).toList();

    return Scaffold(
      
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
                  child: Icon(LucideIcons.arrowLeft, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), size: 22),
                ),
                const SizedBox(width: 16),
                Text("Bills", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), letterSpacing: -1)),
                const Spacer(),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                    builder: (_) => const AddBillForm(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                    child: Icon(LucideIcons.plus, color: Theme.of(context).primaryColor, size: 20),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Text("${unpaid.length} unpaid • ${Formatters.currency(billProv.totalUnpaid, s.currency)} due",
                  style: const TextStyle(color: AppColors.textDim, fontSize: 14)),
              const BannerAdSpace(),
              const SizedBox(height: 10),

              if (unpaid.isEmpty && paid.isEmpty)
                _emptyState()
              else ...[
                if (unpaid.isNotEmpty) ...[
                  const Text("UPCOMING", style: TextStyle(color: AppColors.textDim, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  ...unpaid.map((b) => _billCard(context, b, s.currency, billProv)),
                  const SizedBox(height: 30),
                ],
                if (paid.isNotEmpty) ...[
                  const Text("HISTORY OF PAID BILLS", style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  ...paid.map((b) => _billCard(context, b, s.currency, billProv)),
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
          Icon(LucideIcons.fileText, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.1), size: 48),
          const SizedBox(height: 16),
          const Text("No bills yet", style: TextStyle(color: AppColors.textDim)),
        ]),
      ),
    );
  }

  Widget _billCard(BuildContext context, Bill b, String cur, BillsProvider prov) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(b.dueDate.year, b.dueDate.month, b.dueDate.day);
    final daysLeft = dueDay.difference(today).inDays;
    
    Color borderColor = (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.04);
    
    if (b.isPaid) {
      borderColor = AppColors.success.withOpacity(0.1);
    } else {
      if (daysLeft < 0) borderColor = AppColors.danger;
      else if (daysLeft <= 7) borderColor = AppColors.warning;
    }

    final isOverdue = !b.isPaid && daysLeft < 0;

    var animated = GestureDetector(
      onTap: () => _showBlurMenu(context, b, prov),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor, width: (!b.isPaid && daysLeft <= 7) ? 1.5 : 1.0),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (b.isPaid ? AppColors.success : (isOverdue ? AppColors.danger : (daysLeft <= 7 ? AppColors.warning : Theme.of(context).primaryColor))).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              b.isPaid ? LucideIcons.checkCircle : (isOverdue ? LucideIcons.alertTriangle : (daysLeft <= 7 ? LucideIcons.clock : LucideIcons.fileText)),
              color: b.isPaid ? AppColors.success : (isOverdue ? AppColors.danger : (daysLeft <= 7 ? AppColors.warning : Theme.of(context).primaryColor)), size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(b.name, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.w600, fontSize: 15))),
              if (b.autoPay) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text("AUTO", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 8, fontWeight: FontWeight.w900)),
                ),
              ],
            ]),
            const SizedBox(height: 4),
            Text(b.isPaid ? "${b.frequency} • Paid on ${b.paidDate != null ? Formatters.date(b.paidDate!) : 'Unknown'}" : "${b.frequency} • ${Formatters.date(b.dueDate)}",
                style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
            if (!b.isPaid)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  isOverdue ? "Overdue" : (daysLeft == 0 ? "Due Today" : "Due in $daysLeft days"),
                  style: TextStyle(
                    color: isOverdue ? AppColors.danger : (daysLeft <= 7 ? AppColors.warning : AppColors.textDim),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ])),
          Text(Formatters.currency(b.amount, cur),
              style: TextStyle(color: b.isPaid ? AppColors.success : (isOverdue ? AppColors.danger : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)), fontWeight: FontWeight.bold, fontSize: 15)),
        ]),
      ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
    
    if (context.read<SettingsProvider>().settings.motionBlurEnabled) {
      animated = animated.blurY(begin: 10, end: 0, duration: 400.ms, curve: Curves.easeOut);
    }
    return animated;
  }

  void _showBlurMenu(BuildContext context, Bill b, BillsProvider prov) {
    final sProv = context.read<SettingsProvider>();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "BillOptions",
      pageBuilder: (ctx, a1, a2) => Material(
        type: MaterialType.transparency,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(30),
                border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12)),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(b.name, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 6),
                Text(Formatters.currency(b.amount, sProv.settings.currency),
                    style: const TextStyle(color: AppColors.textDim, fontSize: 14)),
                const SizedBox(height: 30),
                if (!b.isPaid) ...[
                  AppleButton(label: "Pay Bill", onTap: () {
                    Navigator.pop(ctx);
                    _showPaymentDialog(b, prov, sProv);
                  }),
                  const SizedBox(height: 12),
                ],
                AppleButton(label: "Edit Bill", onTap: () {
                  Navigator.pop(ctx);
                  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddBillForm(existingBill: b));
                }),
                const SizedBox(height: 12),
                AppleButton(label: "Delete", isDestructive: true, onTap: () {
                  prov.deleteBill(b.id);
                  SoundService.delete();
                  Navigator.pop(ctx);
                }),
                const SizedBox(height: 12),
                AppleButton(label: "Cancel", bgColor: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12), textColor: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), onTap: () => Navigator.pop(ctx)),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(Bill b, BillsProvider prov, SettingsProvider sProv) {
    String source = b.defaultRouting;
    
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text("Pay Bill", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Amount: ${Formatters.currency(b.amount, sProv.settings.currency)}", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontSize: 16)),
            const SizedBox(height: 20),
            const Text("Funding Source", style: TextStyle(color: AppColors.textDim, fontSize: 12)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: source,
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
              underline: Container(height: 1, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26)),
              items: const [
                DropdownMenuItem(value: 'allowance', child: Text("Monthly Budget")),
                DropdownMenuItem(value: 'resources', child: Text("Available Resources")),
                DropdownMenuItem(value: 'none', child: Text("None (Update only)")),
              ],
              onChanged: (val) {
                if (val != null) setState(() => source = val);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: AppColors.textDim))),
          TextButton(onPressed: () {
            prov.markAsPaid(b.id);
            SoundService.chaching();
            if (source != 'none') {
              final expense = Expense(
                amount: b.amount,
                category: b.category,
                date: DateTime.now(),
                note: 'Bill: ${b.name}',
                lifeCostHours: LifeCostUtils.calculate(b.amount, sProv.settings.hourlyWage),
                fundingSource: source,
              );
              // Deduct from resources if it's budget/resource (ALL real money moves should deduct)
              if (source == 'allowance') {
                context.read<ExpenseProvider>().addExpense(expense, sProv, skipResourceUpdate: true);
              } else if (source == 'resources') {
                context.read<ExpenseProvider>().addExpense(expense, sProv, skipResourceUpdate: true);
                sProv.deductFromResources(b.amount);
              }
            }
            Navigator.pop(ctx);
          }, child: Text("Pay", style: TextStyle(color: Theme.of(context).primaryColor))),
        ],
      )
    ));
  }
}
