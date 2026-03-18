import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../providers/debt_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/debt.dart';
import '../../models/expense.dart';
import '../../utils/life_cost_utils.dart';
import '../../utils/formatters.dart';
import '../../theme/colors.dart';
import '../../widgets/forms/add_debt_form.dart';
import '../../widgets/common/apple_button.dart';
import '../../services/sound_service.dart';
import '../../widgets/common/ad_placements.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});
  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  bool _showOwedToMe = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DebtProvider>().fetchDebts());
  }

  @override
  Widget build(BuildContext context) {
    final debtProv = context.watch<DebtProvider>();
    final s = context.read<SettingsProvider>().settings;
    final filtered = _showOwedToMe
        ? debtProv.debts.where((d) => d.isOwedToMe).toList()
        : debtProv.debts.where((d) => !d.isOwedToMe).toList();

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
                const Text("Debts", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1)),
                const Spacer(),
                GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                    builder: (_) => const AddDebtForm(),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: AppColors.cardBg, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.plus, color: AppColors.primary, size: 20),
                  ),
                ),
              ]),
              const BannerAdSpace(),

              // Summary cards
              Row(children: [
                _summaryPill("Money I Owe", Formatters.currency(debtProv.totalIOwe, s.currency), AppColors.danger, !_showOwedToMe, () => setState(() => _showOwedToMe = false)),
                const SizedBox(width: 10),
                _summaryPill("Owed to Me", Formatters.currency(debtProv.totalOwedToMe, s.currency), AppColors.success, _showOwedToMe, () => setState(() => _showOwedToMe = true)),
              ]),
              const SizedBox(height: 30),

              if (filtered.isEmpty)
                _emptyState()
              else
                ...filtered.map((d) => _debtCard(context, d, s.currency, debtProv)),

              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryPill(String label, String value, Color color, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.12) : AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: active ? color.withOpacity(0.3) : Colors.white.withOpacity(0.04)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: active ? color : AppColors.textDim, fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: active ? color : Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(children: [
          Icon(LucideIcons.arrowLeftRight, color: Colors.white.withOpacity(0.1), size: 48),
          const SizedBox(height: 16),
          const Text("No debts recorded", style: TextStyle(color: AppColors.textDim)),
        ]),
      ),
    );
  }

  Widget _debtCard(BuildContext context, Debt d, String cur, DebtProvider prov) {
    final settled = d.isSettled;
    return GestureDetector(
      onTap: () => _showBlurMenu(context, d, prov),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: settled ? AppColors.success.withOpacity(0.1) : Colors.white.withOpacity(0.04)),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (d.isOwedToMe ? AppColors.success : AppColors.danger).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              d.isOwedToMe ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
              color: d.isOwedToMe ? AppColors.success : AppColors.danger, size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.personName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            Text(d.description.isNotEmpty ? d.description : Formatters.date(d.date),
                style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(Formatters.currency(d.remainingAmount, cur),
                style: TextStyle(color: settled ? AppColors.success : Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            if (settled)
              const Text("Settled", style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
          ]),
        ]),
      ),
    ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOut).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  void _showBlurMenu(BuildContext context, Debt d, DebtProvider prov) {
    final sProv = context.read<SettingsProvider>();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "DebtOptions",
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
                Text(d.personName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 6),
                Text(Formatters.currency(d.remainingAmount, sProv.settings.currency),
                    style: const TextStyle(color: AppColors.textDim, fontSize: 14)),
                const SizedBox(height: 30),
                if (!d.isSettled) ...[
                  AppleButton(label: d.isOwedToMe ? "Receive Payment" : "Make Payment", onTap: () {
                    Navigator.pop(ctx);
                    _showPaymentDialog(d, prov, sProv);
                  }),
                  const SizedBox(height: 12),
                ],
                if (!d.isSettled)
                  AppleButton(label: "Settle All", bgColor: AppColors.success, textColor: Colors.white, onTap: () {
                    prov.settleDebt(d.id);
                    Navigator.pop(ctx);
                  }),
                if (!d.isSettled)
                  const SizedBox(height: 12),
                AppleButton(label: "Edit Debt", onTap: () {
                  Navigator.pop(ctx);
                  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddDebtForm(existingDebt: d));
                }),
                const SizedBox(height: 12),
                AppleButton(label: "Delete", isDestructive: true, onTap: () {
                  prov.deleteDebt(d.id);
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

  void _showPaymentDialog(Debt d, DebtProvider prov, SettingsProvider sProv) {
    final ctrl = TextEditingController();
    String source = 'allowance';
    if (d.defaultRouting == 'Available Resources') source = 'resources';
    if (d.defaultRouting == 'None (Do not log)') source = 'none';
    
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: Text(d.isOwedToMe ? "Receive Payment" : "Payment Amount", style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: ctrl, keyboardType: TextInputType.number, autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: Formatters.currency(d.remainingAmount, sProv.settings.currency),
                hintStyle: const TextStyle(color: Colors.white24),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Funding Source", style: TextStyle(color: AppColors.textDim, fontSize: 12)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: source,
              isExpanded: true,
              dropdownColor: AppColors.cardBg,
              style: const TextStyle(color: Colors.white),
              underline: Container(height: 1, color: Colors.white24),
              items: [
                DropdownMenuItem(value: 'allowance', child: Text("Monthly Budget" + (d.isOwedToMe ? " (Deposit)" : " (Expense)"))),
                const DropdownMenuItem(value: 'resources', child: Text("Available Resources")),
                const DropdownMenuItem(value: 'none', child: Text("None (Update only)")),
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
            final val = double.tryParse(ctrl.text) ?? d.remainingAmount;
            prov.makePayment(d.id, val);
            SoundService.chaching();
            if (source == 'allowance') {
              final expense = Expense(
                amount: d.isOwedToMe ? -val : val,
                category: 'Debts 💳',
                date: DateTime.now(),
                note: d.isOwedToMe ? 'Debt Received: ${d.personName}' : 'Debt Paid: ${d.personName}',
                lifeCostHours: d.isOwedToMe ? 0 : LifeCostUtils.calculate(val, sProv.settings.hourlyWage),
                fundingSource: 'allowance',
              );
              context.read<ExpenseProvider>().addExpense(expense, sProv, skipResourceUpdate: true);
              if (d.isOwedToMe) {
                // Incoming cash always adds to resources
                sProv.addToResources(val);
              }
            } else if (source == 'resources') {
              if (d.isOwedToMe) {
                sProv.addToResources(val);
              } else {
                sProv.deductFromResources(val);
              }
            }
            Navigator.pop(ctx);
          }, child: Text(d.isOwedToMe ? "Receive" : "Pay", style: const TextStyle(color: AppColors.primary))),
        ],
      )
    ));
  }
}
