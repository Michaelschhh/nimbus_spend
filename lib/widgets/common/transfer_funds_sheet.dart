import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/account_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/expense_provider.dart';
import '../../models/account.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import 'apple_button.dart';

class TransferFundsSheet extends StatefulWidget {
  const TransferFundsSheet({super.key});

  @override
  State<TransferFundsSheet> createState() => _TransferFundsSheetState();
}

class _TransferFundsSheetState extends State<TransferFundsSheet> {
  final TextEditingController _amountController = TextEditingController();
  String? _fromId;
  String? _toId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Re-sync balances when the sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().syncBalances();
    });
  }

  @override
  Widget build(BuildContext context) {
    final aProv = context.watch<AccountProvider>();
    final sProv = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cur = sProv.settings.currency;

    if (aProv.accounts.length < 2) {
      return Container(
        height: 250,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))),
        child: const Center(child: Text("You need at least 2 accounts to transfer funds.", style: TextStyle(color: AppColors.textDim))),
      );
    }

    _fromId ??= sProv.currentAccountId;
    _toId ??= aProv.accounts.firstWhere((a) => a.id != _fromId, orElse: () => aProv.accounts.last).id;

    final fromAcc = aProv.accounts.firstWhere((a) => a.id == _fromId);
    final toAcc = aProv.accounts.firstWhere((a) => a.id == _toId);

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 30),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(height: 5, width: 40, decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 25),
            Row(children: [
              Icon(LucideIcons.arrowLeftRight, color: Theme.of(context).primaryColor, size: 22),
              const SizedBox(width: 12),
              Text("Transfer Funds", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, letterSpacing: -0.5)),
            ]),
            const SizedBox(height: 8),
            Text("Move liquidity between your portfolios.", style: TextStyle(color: AppColors.textDim, fontSize: 13)),
            const SizedBox(height: 25),

            // FROM ACCOUNT
            _buildAccountSelector("FROM (DEBIT)", fromAcc, cur, aProv.accounts, (acc) {
              setState(() {
                _fromId = acc.id;
                if (_fromId == _toId) {
                  _toId = aProv.accounts.firstWhere((a) => a.id != _fromId).id;
                }
              });
            }, isDark),

            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.arrowDown, color: Theme.of(context).primaryColor, size: 22),
              ),
            ),
            const SizedBox(height: 12),

            // TO ACCOUNT
            _buildAccountSelector("TO (CREDIT)", toAcc, cur,
              aProv.accounts.where((a) => a.id != _fromId).toList(), (acc) {
              setState(() => _toId = acc.id);
            }, isDark),

            const SizedBox(height: 24),

            // AMOUNT INPUT
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: "Amount",
                  labelStyle: const TextStyle(color: AppColors.textDim),
                  prefixIcon: Icon(LucideIcons.dollarSign, color: Theme.of(context).primaryColor),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 30),
            _isLoading
              ? const Center(child: CircularProgressIndicator())
              : AppleButton(
                  label: "Execute Transfer",
                  bgColor: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onTap: () async {
                    final amount = double.tryParse(_amountController.text) ?? 0;
                    if (amount <= 0) return;
                    if (fromAcc.balance < amount) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Insufficient funds in ${fromAcc.name}. Balance: ${Formatters.currency(fromAcc.balance, cur)}")),
                      );
                      return;
                    }
                    setState(() => _isLoading = true);
                    try {
                      await aProv.transferFunds(_fromId!, _toId!, amount, sProv, context.read<ExpenseProvider>());
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelector(String label, Account current, String cur, List<Account> items, Function(Account) onChanged, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Theme.of(context).primaryColor, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: current.id,
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              icon: Icon(LucideIcons.chevronDown, color: isDark ? Colors.white54 : Colors.black54, size: 18),
              items: items.map((a) => DropdownMenuItem(
                value: a.id,
                child: Row(children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(LucideIcons.wallet, size: 16, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text(a.name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(Formatters.currency(a.balance, cur), style: TextStyle(color: a.balance > 0 ? AppColors.success : AppColors.textDim, fontSize: 12, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ]),
              )).toList(),
              onChanged: (id) {
                if (id != null) {
                  final acc = items.firstWhere((a) => a.id == id);
                  onChanged(acc);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
