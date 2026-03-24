import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/account_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../utils/responsive.dart';
import '../../models/account.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/savings_provider.dart';
import '../../providers/bills_provider.dart';
import '../../providers/debt_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/shopping_provider.dart';
import 'apple_button.dart';
import 'transfer_funds_sheet.dart';

class AccountManagementBottomSheet extends StatefulWidget {
  const AccountManagementBottomSheet({super.key});

  @override
  State<AccountManagementBottomSheet> createState() => _AccountManagementBottomSheetState();
}

class _AccountManagementBottomSheetState extends State<AccountManagementBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final aProv = context.watch<AccountProvider>();
    final sProv = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 30),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(height: 5, width: 40, decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 25),
          Text("Financial Persona", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text("Manage your specialized accounts and funding sources.", style: TextStyle(color: AppColors.textDim, fontSize: 13)),
          const SizedBox(height: 25),

          Expanded(
            child: ListView.builder(
              itemCount: aProv.accounts.length,
              itemBuilder: (context, index) {
                final acc = aProv.accounts[index];
                final isActive = acc.id == sProv.currentAccountId;
                
                return InkWell(
                  onTap: () {
                    if (isActive) return;
                    sProv.switchAccount(acc.id, () {
                      context.read<ExpenseProvider>().fetchExpenses();
                      context.read<IncomeProvider>().fetchIncomes();
                      context.read<SavingsProvider>().fetchSavings();
                      context.read<BillsProvider>().fetchBills();
                      context.read<DebtProvider>().fetchDebts();
                      context.read<GoalsProvider>().fetchGoals();
                      context.read<SubscriptionProvider>().fetchSubscriptions();
                      context.read<ShoppingProvider>().fetchLists();
                      Navigator.pop(context);
                    });
                  },
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isActive ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: isActive ? Theme.of(context).primaryColor : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(isActive ? 0.2 : 0.1), borderRadius: BorderRadius.circular(14)),
                          child: Icon(acc.icon != null ? _getIconData(acc.icon!) : LucideIcons.wallet, color: Theme.of(context).primaryColor, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              acc.name + (acc.id == 'default' ? ' (Main)' : ''), 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isActive ? Theme.of(context).primaryColor : (isDark ? Colors.white : Colors.black))
                            ),
                            if (isActive)
                              Text("Active", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                        if (aProv.accounts.length > 1 && acc.id != 'default')
                          IconButton(onPressed: () => aProv.deleteAccount(acc.id), icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.danger)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
          if (!sProv.settings.isPro && aProv.accounts.length >= 2)
            _proBadge(context)
          else
            AppleButton(
              label: "Add New Portfolio", 
              onTap: () => _showAddDialog(context, aProv, sProv),
              bgColor: Theme.of(context).primaryColor,
              textColor: Colors.white,
            ),
          const SizedBox(height: 12),
          if (aProv.accounts.length > 1)
            AppleButton(
              label: "Transfer Funds", 
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => const TransferFundsSheet());
              },
              bgColor: Theme.of(context).primaryColor.withOpacity(0.1),
              textColor: Theme.of(context).primaryColor,
            ),
        ],
      ),
    );
  }

  Widget _proBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.warning.withOpacity(0.3))),
      child: Row(children: [
        const Icon(LucideIcons.crown, color: AppColors.warning, size: 20),
        const SizedBox(width: 12),
        const Expanded(child: Text("Pro members can manage unlimited specialized accounts.", style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold))),
      ]),
    );
  }

  void _showAddDialog(BuildContext context, AccountProvider aProv, SettingsProvider sProv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("New Account"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Account Name (e.g. Crypto, Cash)")),
            TextField(controller: _balanceController, decoration: const InputDecoration(labelText: "Initial Balance"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final name = _nameController.text;
              final balance = double.tryParse(_balanceController.text) ?? 0;
              if (name.isNotEmpty) {
                aProv.addAccount(Account(id: DateTime.now().toIso8601String(), name: name, balance: balance, icon: "wallet"), sProv);
                _nameController.clear();
                _balanceController.clear();
                Navigator.pop(ctx);
              }
            }, 
            child: Text("Create", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'wallet': return LucideIcons.wallet;
      case 'bank': return LucideIcons.landmark;
      case 'card': return LucideIcons.creditCard;
      default: return LucideIcons.coins;
    }
  }
}
