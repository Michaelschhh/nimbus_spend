import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../utils/formatters.dart';
import '../../utils/color_utils.dart';
import '../../utils/responsive.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _customStartDate;
  int _touchedPieIndex = -1;
  int _touchedBarIndex = -1;

  @override
  Widget build(BuildContext context) {
    final eProv = context.watch<ExpenseProvider>();
    final sProv = context.watch<SettingsProvider>();
    final s = sProv.settings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    final earliestDate = eProv.expenses.isEmpty
        ? DateTime.now()
        : eProv.expenses.map((e) => e.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final activeStartDate = _customStartDate ?? earliestDate;

    final filteredExpenses = eProv.expenses
        .where((e) => e.date.isAfter(activeStartDate.subtract(const Duration(minutes: 1))))
        .toList();

    final Map<String, double> categoryTotals = {};
    for (var e in filteredExpenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }
    double total = categoryTotals.values.fold(0, (sum, val) => sum + val);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Responsive.sp(24, context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Analytics",
                      style: TextStyle(
                          fontSize: Responsive.fs(34, context),
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -1.2)),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                      ]
                    ),
                    child: IconButton(
                      onPressed: () => _shareTranscript(context, eProv.expenses, total, s.currency, s.name),
                      icon: Icon(LucideIcons.share2, color: Theme.of(context).primaryColor, size: 20),
                    ),
                  ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                ],
              ),
              const SizedBox(height: 16),

              // DATE RANGE SELECTOR
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(LucideIcons.calendar, size: 14, color: Theme.of(context).primaryColor)
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Timeframe", style: TextStyle(color: AppColors.textDim, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text("Since ${Formatters.dateMonthYear(activeStartDate)}",
                              style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ]),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: activeStartDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: isDark ? const ColorScheme.dark() : const ColorScheme.light(),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) setState(() => _customStartDate = date);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)]),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                          ]
                        ),
                        child: const Text("Change", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, curve: Curves.easeOut),
              const SizedBox(height: 24),

              // TOTAL SPEND SUMMARY
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).cardColor, Theme.of(context).cardColor.withOpacity(0.8)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("TOTAL SPEND", style: TextStyle(color: AppColors.textDim, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 12),
                    Text(Formatters.currency(total, s.currency),
                        style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -2)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.lifeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text("${filteredExpenses.length} total transactions",
                          style: const TextStyle(color: AppColors.lifeColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.2, curve: Curves.easeOut),
              const SizedBox(height: 32),

              // PIE CHART — Spending Distribution
              _sectionTitle("Spending Distribution", LucideIcons.pieChart),
              const SizedBox(height: 16),
              Container(
                height: 320,
                padding: const EdgeInsets.all(24),
                decoration: _cardDecoration(isDark),
                child: total == 0
                    ? _emptyChart()
                    : Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection == null) {
                                        _touchedPieIndex = -1;
                                        return;
                                      }
                                      _touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                    });
                                  },
                                ),
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: _buildPieSections(categoryTotals, total, isDark),
                              ),
                            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 4,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _buildLegendItems(categoryTotals, total, textColor),
                              ),
                            ),
                          ),
                        ],
                      ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2, curve: Curves.easeOut),
              const SizedBox(height: 32),

              // BAR CHART — Top Categories
              _sectionTitle("Top Categories", LucideIcons.barChart2),
              const SizedBox(height: 16),
              Container(
                height: 280,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                decoration: _cardDecoration(isDark),
                child: total == 0 ? _emptyChart() : _buildBarChart(categoryTotals, s.currency),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.2, curve: Curves.easeOut),
              const SizedBox(height: 32),

              // LINE CHART — Balance Over Time
              _sectionTitle("Balance Trend", LucideIcons.trendingUp),
              const SizedBox(height: 16),
              Container(
                height: 260,
                padding: const EdgeInsets.fromLTRB(16, 24, 24, 8),
                decoration: _cardDecoration(isDark),
                child: _buildLineChart(eProv, sProv),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.2, curve: Curves.easeOut),
              const SizedBox(height: 32),

              // SUMMARY OBSERVATIONS
              _sectionTitle("Intelligence Summary", LucideIcons.brainCircuit),
              const SizedBox(height: 16),
              _buildInsightSummary(eProv, sProv, isDark),
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HELPERS ──────────────────────

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: (isDark ? Colors.white : Colors.black).withOpacity(0.03)),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))
      ]
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    final textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5)),
      ],
    );
  }

  Widget _emptyChart() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.barChart2, size: 48, color: AppColors.textDim.withOpacity(0.3)),
        const SizedBox(height: 16),
        const Text("Not enough data to model", style: TextStyle(color: AppColors.textDim, fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _cleanCategoryName(String category) {
    String clean = category.replaceAll(RegExp(r'[^\w\s]+'), '').trim();
    return clean.isEmpty ? category : clean;
  }

  // ─── PIE CHART ────────────────────

  List<PieChartSectionData> _buildPieSections(Map<String, double> dataMap, double total, bool isDark) {
    Map<String, double> grouped = {};
    double otherTotal = 0;
    for (var entry in dataMap.entries) {
      if ((entry.value / total) < 0.05) {
        otherTotal += entry.value;
      } else {
        grouped[entry.key] = entry.value;
      }
    }
    if (otherTotal > 0) grouped["Other"] = otherTotal;

    var sorted = grouped.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == _touchedPieIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final pct = (data.value / total * 100);

      return PieChartSectionData(
        color: ColorUtils.categoryColor(data.key, context),
        value: data.value,
        title: "${pct.toStringAsFixed(0)}%",
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
        ),
        badgeWidget: isTouched ? _buildBadge(data.key, data.value) : null,
        badgePositionPercentageOffset: 1.2,
      );
    }).toList();
  }
  
  Widget _buildBadge(String category, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Text(_cleanCategoryName(category), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  List<Widget> _buildLegendItems(Map<String, double> dataMap, double total, Color textColor) {
    Map<String, double> grouped = {};
    double otherTotal = 0;
    for (var entry in dataMap.entries) {
      if ((entry.value / total) < 0.05) {
        otherTotal += entry.value;
      } else {
        grouped[entry.key] = entry.value;
      }
    }
    if (otherTotal > 0) grouped["Other"] = otherTotal;

    var sorted = grouped.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((entry) {
      final pct = (entry.value / total * 100).toStringAsFixed(0);
      final name = _cleanCategoryName(entry.key);
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Container(
            width: 12, height: 12, 
            decoration: BoxDecoration(
              color: ColorUtils.categoryColor(entry.key, context),
              shape: BoxShape.circle,
            )
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text("$pct%", style: const TextStyle(color: AppColors.textDim, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          )),
        ]),
      );
    }).toList();
  }

  // ─── BAR CHART ────────────────────

  Widget _buildBarChart(Map<String, double> dataMap, String cur) {
    var sorted = dataMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    sorted = sorted.take(6).toList();

    List<BarChartGroupData> groups = [];
    double maxY = 0;
    
    for (int i = 0; i < sorted.length; i++) {
      if (sorted[i].value > maxY) maxY = sorted[i].value;
      final isTouched = i == _touchedBarIndex;
      groups.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: sorted[i].value,
            color: isTouched ? Theme.of(context).primaryColor : ColorUtils.categoryColor(sorted[i].key, context).withOpacity(0.8),
            width: 24,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY * 1.2,
              color: Theme.of(context).primaryColor.withOpacity(0.05),
            ),
          )
        ],
      ));
    }

    return BarChart(
      BarChartData(
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                Formatters.currency(rod.toY, cur),
                TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions || barTouchResponse == null || barTouchResponse.spot == null) {
                _touchedBarIndex = -1;
                return;
              }
              _touchedBarIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            });
          },
        ),
        alignment: BarChartAlignment.spaceAround,
        barGroups: groups,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: AppColors.textDim.withOpacity(0.1), strokeWidth: 1, dashArray: [5, 5])
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx >= sorted.length) return const SizedBox();
                final name = _cleanCategoryName(sorted[idx].key);
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    name.length > 7 ? "${name.substring(0, 6)}…" : name,
                    style: const TextStyle(fontSize: 10, color: AppColors.textDim, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }

  // ─── LINE CHART ───────────────────

  Widget _buildLineChart(ExpenseProvider eProv, SettingsProvider sProv) {
    final now = DateTime.now();
    List<FlSpot> spots = [];
    double currentNet = sProv.settings.availableResources;

    for (int i = 0; i < 6; i++) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);
      spots.insert(0, FlSpot((5 - i).toDouble(), currentNet));

      final monthExpenses = eProv.expenses
          .where((e) => e.date.isAfter(monthDate.subtract(const Duration(seconds: 1))) && e.date.isBefore(monthEnd.add(const Duration(seconds: 1))))
          .fold(0.0, (sum, e) => sum + e.amount);
      currentNet -= (eProv.expenses.isNotEmpty ? monthExpenses : 0);
    }

    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Theme.of(context).primaryColor,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) => LineTooltipItem(
                Formatters.currency(spot.y, sProv.settings.currency),
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
              )).toList();
            }
          )
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: spots.isNotEmpty ? ((spots.map((s) => s.y).reduce((a,b) => a > b ? a : b) - spots.map((s) => s.y).reduce((a,b) => a < b ? a : b)) / 3).clamp(1, double.infinity) : 1,
          getDrawingHorizontalLine: (value) => FlLine(color: AppColors.textDim.withOpacity(0.1), strokeWidth: 1, dashArray: [4, 4]),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final month = (now.month - (5 - val.toInt()));
                final adjustedMonth = ((month - 1) % 12 + 12) % 12;
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(months[adjustedMonth], style: const TextStyle(fontSize: 11, color: AppColors.textDim, fontWeight: FontWeight.bold)),
                );
              },
              interval: 1,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: Theme.of(context).primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            shadow: Shadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: Theme.of(context).primaryColor,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor.withOpacity(0.3), Theme.of(context).primaryColor.withOpacity(0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SUMMARY TILES ────────────────

  Widget _buildInsightSummary(ExpenseProvider eProv, SettingsProvider sProv, bool isDark) {
    final s = sProv.settings;
    final totalSpent = eProv.totalSpentThisMonth;
    final daysPassed = DateTime.now().day;
    final avgDaily = daysPassed > 0 ? totalSpent / daysPassed : 0.0;
    final projectedMonth = avgDaily * 30;

    return Column(
      children: [
        _insightTile("Monthly Projection", Formatters.currency(projectedMonth, s.currency),
            projectedMonth > s.monthlyBudget ? AppColors.danger : AppColors.success, LucideIcons.target, isDark),
        _insightTile("Daily Average", Formatters.currency(avgDaily, s.currency), AppColors.lifeColor, LucideIcons.activity, isDark),
        _insightTile("Dominant Category", _getTopCategory(eProv), Theme.of(context).primaryColor, LucideIcons.award, isDark),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.2, curve: Curves.easeOut);
  }

  String _getTopCategory(ExpenseProvider eProv) {
    if (eProv.expenses.isEmpty) return "None";
    Map<String, double> cats = {};
    for (var e in eProv.expenses) {
      cats[e.category] = (cats[e.category] ?? 0) + e.amount;
    }
    final sorted = cats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return _cleanCategoryName(sorted.first.key);
  }

  Widget _insightTile(String label, String value, Color color, IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 16, color: color)
              ),
              const SizedBox(width: 16),
              Text(label, style: const TextStyle(color: AppColors.textDim, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  // ─── SHARE ────────────────────────

  void _shareTranscript(BuildContext context, List<dynamic> expenses, double total, String cur, String name) {
    String transcript = "--- NIMBUS SPEND ANALYTICS ---\n";
    transcript += "Report for $name\n";
    transcript += "Period: ${DateTime.now().month}/${DateTime.now().year}\n";
    transcript += "Gross Spend: ${Formatters.currency(total, cur)}\n\n";

    Map<String, double> summary = {};
    for (var e in expenses) {
      summary[e.category] = (summary[e.category] ?? 0) + e.amount;
    }
    summary.forEach((k, v) {
      transcript += "• ${_cleanCategoryName(k)}: ${Formatters.currency(v, cur)}\n";
    });

    transcript += "\nDriven by Nimbus Intelligence Core.";
    Share.share(transcript, subject: "Financial Insights");
  }
}