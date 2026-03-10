import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expProv = context.watch<ExpenseProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final now = DateTime.now();
    final expenses = expProv.expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
    
    Map<String, double> dataMap = {};
    double total = 0;
    for (var e in expenses) {
      dataMap[e.category] = (dataMap[e.category] ?? 0) + e.amount;
      total += e.amount;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Analysis", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 35),
              
              if (expenses.isEmpty)
                const Center(child: Text("No data for current cycle.", style: TextStyle(color: AppColors.textDim)))
              else ...[
                Container(
                  height: 300, width: double.infinity,
                  decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(32)),
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 6,
                      centerSpaceRadius: 60,
                      sections: dataMap.entries.map((entry) {
                        double pct = (entry.value / total) * 100;
                        return PieChartSectionData(
                          color: _colorFor(entry.key),
                          value: entry.value,
                          title: "${pct.toStringAsFixed(0)}%",
                          radius: 30,
                          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ...dataMap.entries
                    .map((entry) => _row(entry.key, entry.value, settings.currency)),
              ],
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorFor(String c) {
    if (c.contains("Food")) return AppColors.success;
    if (c.contains("Shopping")) return AppColors.primary;
    if (c.contains("Bills")) return AppColors.warning;
    return AppColors.lifeColor;
  }

  Widget _row(String k, double v, String cur) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(22)),
    child: Row(children: [
      CircleAvatar(radius: 5, backgroundColor: _colorFor(k)),
      const SizedBox(width: 15),
      Expanded(child: Text(k, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
      Text(Formatters.currency(v, cur), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ]),
  );
}