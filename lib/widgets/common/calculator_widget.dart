import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:math_expressions/math_expressions.dart';
import '../../theme/colors.dart';
import '../../utils/responsive.dart';
import 'apple_button.dart';
import '../forms/add_expense_form.dart';
import '../forms/add_income_form.dart';
import '../../models/expense.dart';
import '../../models/income.dart';
import '../../models/bill.dart';
import '../../models/debt.dart';
import '../forms/add_saving_form.dart';
import '../forms/add_bill_form.dart';
import '../forms/add_debt_form.dart';

class CalculatorWidget extends StatefulWidget {
  const CalculatorWidget({super.key});

  @override
  State<CalculatorWidget> createState() => _CalculatorWidgetState();
}

class _CalculatorWidgetState extends State<CalculatorWidget> {
  String _input = "";
  String _result = "0";

  void _onPressed(String label) {
    setState(() {
      if (label == "C") {
        _input = "";
        _result = "0";
      } else if (label == "=") {
        try {
          Parser p = Parser();
          Expression exp = p.parse(_input.replaceAll('x', '*').replaceAll('÷', '/').replaceAll('%', '/100'));
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          _result = eval.toStringAsFixed(2);
          _input = _result;
        } catch (e) {
          _result = "Error";
        }
      } else if (label == "⌫") {
        if (_input.isNotEmpty) _input = _input.substring(0, _input.length - 1);
      } else {
        _input += label;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
      ),
      child: Column(
        children: [
          Container(height: 5, width: 40, decoration: BoxDecoration(color: (isDark ? Colors.white10 : Colors.black12), borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 30),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_input, style: TextStyle(fontSize: 24, color: AppColors.textDim)),
                  Text(_result, style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                "C", "(", ")", "⌫",
                "7", "8", "9", "÷",
                "4", "5", "6", "x",
                "1", "2", "3", "-",
                "0", ".", "%", "+",
                " ", " ", " ", "="
              ].map((label) {
                if (label == " ") return const SizedBox();
                bool isOp = ["÷", "x", "-", "+", "=", "C", "⌫"].contains(label);
                return GestureDetector(
                  onTap: () => _onPressed(label),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isOp ? Theme.of(context).primaryColor.withOpacity(0.15) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isOp ? Theme.of(context).primaryColor : (isDark ? Colors.white : Colors.black))),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _calcAction("Expense", AppColors.danger, () {
                    final valStr = _result != "Error" && _result.isNotEmpty ? _result : "0.0";
                    final val = double.tryParse(valStr) ?? 0.0;
                    if (val > 0) {
                      Navigator.pop(context);
                      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddExpenseForm(existingExpense: Expense(amount: val, category: 'Shopping', date: DateTime.now(), note: 'From Calculator', lifeCostHours: 0)));
                    }
                }),
                const SizedBox(width: 8),
                _calcAction("Income", AppColors.success, () {
                    final valStr = _result != "Error" && _result.isNotEmpty ? _result : "0.0";
                    final val = double.tryParse(valStr) ?? 0.0;
                    if (val > 0) {
                      Navigator.pop(context);
                      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddIncomeForm(existingIncome: Income(amount: val, date: DateTime.now(), source: 'Calculator', note: '')));
                    }
                }),
                const SizedBox(width: 8),
                _calcAction("Savings", AppColors.primary, () {
                    final valStr = _result != "Error" && _result.isNotEmpty ? _result : "0.0";
                    final val = double.tryParse(valStr) ?? 0.0;
                    if (val > 0) {
                      Navigator.pop(context);
                      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddSavingForm(initialAmount: val));
                    }
                }),
                const SizedBox(width: 8),
                _calcAction("Bill", AppColors.warning, () {
                    final valStr = _result != "Error" && _result.isNotEmpty ? _result : "0.0";
                    final val = double.tryParse(valStr) ?? 0.0;
                    if (val > 0) {
                      Navigator.pop(context);
                      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddBillForm(existingBill: Bill(name: '', amount: val, dueDate: DateTime.now(), frequency: 'Monthly', category: 'Bills 📄')));
                    }
                }),
                const SizedBox(width: 8),
                _calcAction("Debt", AppColors.info, () {
                    final valStr = _result != "Error" && _result.isNotEmpty ? _result : "0.0";
                    final val = double.tryParse(valStr) ?? 0.0;
                    if (val > 0) {
                      Navigator.pop(context);
                      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddDebtForm(existingDebt: Debt(personName: '', amount: val, description: 'From Calculator', date: DateTime.now(), isOwedToMe: false)));
                    }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _calcAction(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}
