import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/bills_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/formatters.dart';
import '../../theme/colors.dart';
import '../../widgets/forms/add_bill_form.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  @override
  Widget build(BuildContext context) {
    final billProv = context.watch<BillsProvider>();
    final currency = context.read<SettingsProvider>().settings.currency;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bill Calendar",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUpcomingSummary(billProv, currency),
            const SizedBox(height: 30),
            const Text(
              "Upcoming Bills",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            if (billProv.bills.isEmpty)
              const Center(child: Text("No bills tracked yet."))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: billProv.bills.length,
                itemBuilder: (context, index) {
                  final bill = billProv.bills[index];
                  final isOverdue = bill.dueDate.isBefore(now) && !bill.isPaid;
                  final isSoon =
                      bill.dueDate.difference(now).inDays <= 3 && !bill.isPaid;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ListTile(
                      leading: Icon(
                        LucideIcons.calendar,
                        color: bill.isPaid
                            ? AppColors.success
                            : (isOverdue
                                  ? AppColors.danger
                                  : (isSoon
                                        ? AppColors.warning
                                        : AppColors.primary)),
                      ),
                      title: Text(
                        bill.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Due: ${Formatters.date(bill.dueDate)}"),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.currency(bill.amount, currency),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (!bill.isPaid)
                            GestureDetector(
                              onTap: () => billProv.markAsPaid(bill.id),
                              child: const Text(
                                "Mark Paid",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            const Icon(
                              LucideIcons.checkCircle,
                              color: AppColors.success,
                              size: 16,
                            ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (index * 100).ms).slideX();
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBill(context),
        backgroundColor: AppColors.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  Widget _buildUpcomingSummary(BillsProvider prov, String currency) {
    final totalUnpaid = prov.bills
        .where((b) => !b.isPaid)
        .fold(0.0, (sum, b) => sum + b.amount);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            "UNPAID BILLS",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.currency(totalUnpaid, currency),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBill(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddBillForm(),
    );
  }
}
