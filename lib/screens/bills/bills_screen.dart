import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                const Text("Bills", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1)),
                const Spacer(),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                    builder: (_) => const AddBillForm(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: AppColors.cardBg, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.plus, color: AppColors.primary, size: 20),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Text("${unpaid.length} unpaid • ${Formatters.currency(billProv.totalUnpaid, s.currency)} due",
                  style: const TextStyle(color: AppColors.textDim, fontSize: 14)),
              const SizedBox(height: 30),

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
                  const Text("PAID", style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
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
          Icon(LucideIcons.fileText, color: Colors.white.withOpacity(0.1), size: 48),
          const SizedBox(height: 16),
          const Text("No bills yet", style: TextStyle(color: AppColors.textDim)),
        ]),
      ),
    );
  }

  Widget _billCard(BuildContext context, Bill b, String cur, BillsProvider prov) {
    return GestureDetector(
      onLongPress: () => _showBlurMenu(context, b, prov),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: b.isPaid ? AppColors.success.withOpacity(0.1) : Colors.white.withOpacity(0.04)),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (b.isPaid ? AppColors.success : AppColors.warning).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              b.isPaid ? LucideIcons.checkCircle : LucideIcons.clock,
              color: b.isPaid ? AppColors.success : AppColors.warning, size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(b.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            Text("${b.frequency} • Due ${Formatters.date(b.dueDate)}",
                style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
          ])),
          Text(Formatters.currency(b.amount, cur),
              style: TextStyle(color: b.isPaid ? AppColors.success : Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ]),
      ),
    );
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
                color: AppColors.cardBg, borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(b.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 6),
                Text(Formatters.currency(b.amount, sProv.settings.currency),
                    style: const TextStyle(color: AppColors.textDim, fontSize: 14)),
                const SizedBox(height: 30),
                if (!b.isPaid) ...[
                  AppleButton(label: "Pay from Allowance", onTap: () {
                    Navigator.pop(ctx);
                    _payBill(b, 'allowance', prov, sProv);
                  }),
                  const SizedBox(height: 12),
                  AppleButton(label: "Pay from Resources", bgColor: AppColors.primary, textColor: Colors.white, onTap: () {
                    Navigator.pop(ctx);
                    _payBill(b, 'resources', prov, sProv);
                  }),
                  const SizedBox(height: 12),
                ],
                AppleButton(label: "Delete Bill", isDestructive: true, onTap: () {
                  prov.deleteBill(b.id);
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

  void _payBill(Bill b, String source, BillsProvider billProv, SettingsProvider sProv) {
    billProv.markAsPaid(b.id);
    if (source == 'allowance') {
      final expense = Expense(
        amount: b.amount,
        category: b.category,
        date: DateTime.now(),
        note: 'Bill: ${b.name}',
        lifeCostHours: LifeCostUtils.calculate(b.amount, sProv.settings.hourlyWage),
      );
      context.read<ExpenseProvider>().addExpense(expense, sProv);
    } else {
      sProv.deductFromResources(b.amount);
    }
  }
}
