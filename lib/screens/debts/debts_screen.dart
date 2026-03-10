import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/debt_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/formatters.dart';
import '../../theme/colors.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final debtProv = context.watch<DebtProvider>();
    final currency = context.read<SettingsProvider>().settings.currency;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Debt Tracker",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "I Owe"),
            Tab(text: "Owed to Me"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDebtList(
            debtProv.debts.where((d) => !d.isOwedToMe).toList(),
            currency,
            debtProv,
          ),
          _buildDebtList(
            debtProv.debts.where((d) => d.isOwedToMe).toList(),
            currency,
            debtProv,
          ),
        ],
      ),
    );
  }

  Widget _buildDebtList(
    List<dynamic> list,
    String currency,
    DebtProvider prov,
  ) {
    if (list.isEmpty) {
      return const Center(child: Text("Clear! No active debts here."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final debt = list[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: debt.isSettled
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.danger.withOpacity(0.1),
              child: Icon(
                debt.isOwedToMe
                    ? LucideIcons.arrowDownLeft
                    : LucideIcons.arrowUpRight,
                color: debt.isSettled ? AppColors.success : AppColors.danger,
                size: 20,
              ),
            ),
            title: Text(
              debt.personName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(debt.description),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.currency(debt.amount, currency),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (!debt.isSettled)
                  GestureDetector(
                    onTap: () => prov.settleDebt(debt.id),
                    child: const Text(
                      "Settle",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const Text(
                    "Settled ✅",
                    style: TextStyle(color: AppColors.success, fontSize: 12),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
