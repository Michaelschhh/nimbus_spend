import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/life_cost_utils.dart';
import '../../widgets/forms/add_subscription_form.dart';
import '../../theme/colors.dart';
import '../../services/ad_service.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subProv = context.watch<SubscriptionProvider>();
    final settings = context.watch<SettingsProvider>().settings;

    // Calculate totals
    final monthlyTotal = subProv.monthlySubCost;
    final annualTotal = monthlyTotal * 12;
    final annualLifeHours = LifeCostUtils.calculate(
      annualTotal,
      settings.hourlyWage,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Subscriptions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Summary Card
            _buildSummaryCard(annualTotal, annualLifeHours, settings.currency),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Active Subscriptions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${subProv.subscriptions.length} Tracked",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 15),

            if (subProv.subscriptions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    "No subscriptions yet. Track your recurring costs!",
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: subProv.subscriptions.length,
                itemBuilder: (context, index) {
                  final sub = subProv.subscriptions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(
                          LucideIcons.refreshCw,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        sub.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Next: ${Formatters.date(sub.nextDueDate)}",
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.currency(sub.amount, settings.currency),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            sub.frequency,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (index * 100).ms);
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _handleAddButton(context, subProv.subscriptions.length),
        label: const Text(
          "Add Subscription",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSummaryCard(double annual, double life, String currency) {
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
            "ANNUAL COST",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.currency(annual, currency),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "That's ${LifeCostUtils.format(life)} of your work every year",
            style: const TextStyle(
              color: AppColors.lifeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2);
  }

  void _handleAddButton(BuildContext context, int count) {
    if (count >= 1) {
      // THE AD GATE: Show dialog before showing Ad
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Unlock New Slot"),
          content: const Text(
            "Watch a short ad to add another recurring payment to your list.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                AdService.showRewardedAd(() {
                  _showAddForm(context);
                });
              },
              child: const Text("Watch Ad"),
            ),
          ],
        ),
      );
    } else {
      // First one is free!
      _showAddForm(context);
    }
  }

  void _showAddForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddSubscriptionForm(),
    );
  }
}
