import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/ad_placements.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _showBarChart = false;

  @override
  Widget build(BuildContext context) {
    final expProv = context.watch<ExpenseProvider>();
    final sProv = context.watch<SettingsProvider>();
    final settings = sProv.settings;
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
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Analysis", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))),
                  IconButton(
                    onPressed: () => _shareTranscript(context, expenses, total, settings.currency, settings.name),
                    icon: const Icon(Icons.ios_share, color: AppColors.primary),
                  ),
                ],
              ),
              const BannerAdSpace(),
              const SizedBox(height: 15),
              
              if (expenses.isEmpty)
                const Center(child: Text("No data for current cycle.", style: TextStyle(color: AppColors.textDim)))
              else ...[
                // CHART TOGGLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _toggleBtn("Pie", !_showBarChart, () => setState(() => _showBarChart = false)),
                    const SizedBox(width: 10),
                    _toggleBtn("Bars", _showBarChart, () => setState(() => _showBarChart = true)),
                  ],
                ),
                const SizedBox(height: 25),

                Container(
                  height: 300, width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(32)),
                  child: _showBarChart ? _buildBarChart(dataMap, total) : _buildPieChart(dataMap, total),
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

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: active ? Theme.of(context).scaffoldBackgroundColor : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> dataMap, double total) {
    return PieChart(
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
            titleStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> dataMap, double total) {
    final entries = dataMap.entries.toList();
    final maxVal = dataMap.values.fold(0.0, (max, v) => v > max ? v : max);
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal * 1.3,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final cat = entries[group.x].key;
              return BarTooltipItem(
                '$cat\n${Formatters.currency(rod.toY, '')}',
                TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= entries.length) return const SizedBox.shrink();
                String label = entries[value.toInt()].key;
                if (label.length > 5) label = '${label.substring(0, 5)}..';
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(label, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54), fontSize: 9, fontWeight: FontWeight.w600)),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxVal > 0 ? maxVal / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.06),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((group) {
          final color = _colorFor(group.value.key);
          return BarChartGroupData(
            x: group.key,
            barRods: [
              BarChartRodData(
                toY: group.value.value,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [color.withOpacity(0.5), color],
                ),
                width: 22,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxVal * 1.3,
                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.03),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _shareTranscript(BuildContext context, List<dynamic> expenses, double total, String cur, String name) {
    String transcript = "--- NIMBUS SPEND REPORT ---\n";
    transcript += "User: $name\n";
    transcript += "Month: ${DateTime.now().month}/${DateTime.now().year}\n";
    transcript += "Total Spend: ${Formatters.currency(total, cur)}\n\n";
    transcript += "Breakdown:\n";
    
    Map<String, double> summary = {};
    for (var e in expenses) {
      summary[e.category] = (summary[e.category] ?? 0) + e.amount;
    }
    
    summary.forEach((k, v) {
      transcript += "• $k: ${Formatters.currency(v, cur)}\n";
    });

    transcript += "\nGenerated by Nimbus - Premium Financial Intelligence";
    Share.share(transcript, subject: "Nimbus Spend Transcript");
  }

  Color _colorFor(String c) {
    if (c.contains("Food")) return AppColors.success;
    if (c.contains("Shopping")) return AppColors.primary;
    if (c.contains("Bills")) return AppColors.warning;
    if (c.contains("Transport")) return AppColors.info;
    if (c.contains("Health")) return AppColors.danger;
    return AppColors.lifeColor;
  }

  Widget _row(String k, double v, String cur) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(22)),
    child: Row(children: [
      CircleAvatar(radius: 5, backgroundColor: _colorFor(k)),
      const SizedBox(width: 15),
      Expanded(child: Text(k, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.w600))),
      Text(Formatters.currency(v, cur), style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
    ]),
  );
}