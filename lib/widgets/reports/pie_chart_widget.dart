import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/expense.dart';

class CategoryPieChart extends StatelessWidget {
  final List<Expense> expenses;

  const CategoryPieChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final categoryTotals = <String, double>{};
    double totalSpend = 0;

    for (var ex in expenses) {
      categoryTotals[ex.category] =
          (categoryTotals[ex.category] ?? 0) + ex.amount;
      totalSpend += ex.amount;
    }

    if (totalSpend == 0) {
      return const Center(child: Text("No data to display"));
    }

    final List<PieChartSectionData> sections = [];
    final categories = categoryTotals.keys.toList();

    for (int i = 0; i < categories.length; i++) {
      final cat = categories[i];
      final val = categoryTotals[cat]!;
      final percentage = (val / totalSpend) * 100;

      sections.add(
        PieChartSectionData(
          color: Colors.primaries[i % Colors.primaries.length],
          value: val,
          title: '${percentage.toStringAsFixed(0)}%',
          radius: 60,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: categories.map((cat) {
            final index = categories.indexOf(cat);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.primaries[index % Colors.primaries.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(cat, style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
