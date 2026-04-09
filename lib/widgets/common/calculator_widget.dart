import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../services/shader_service.dart';
import '../../theme/colors.dart';
import '../../utils/responsive.dart';
import '../../providers/settings_provider.dart';
import 'liquid_physics_button.dart';
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

class _CalculatorWidgetState extends State<CalculatorWidget> with SingleTickerProviderStateMixin {
  String _input = "";
  String _result = "0";
  Offset _dragOffset = Offset.zero;
  late AnimationController _tiltController;

  @override
  void initState() {
    super.initState();
    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _tiltController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      // Limit tilt
      _dragOffset = Offset(
        _dragOffset.dx.clamp(-30.0, 30.0),
        _dragOffset.dy.clamp(-30.0, 30.0),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _tiltController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _dragOffset = Offset.zero;
        });
      }
    });
  }

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
    final s = context.watch<SettingsProvider>().settings;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWater = s.liquidEffectEnabled;

    Widget body = Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.82, // Locks strict dynamic ratio height resolving unbounded flex limits
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          decoration: BoxDecoration(
            color: isWater 
                ? (isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4))
                : Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                border: isWater ? Border.all(color: Colors.white.withOpacity(0.4), width: 1.5) : null,
              ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 5, width: 40, decoration: BoxDecoration(color: (isDark || isWater ? Colors.white24 : Colors.black12), borderRadius: BorderRadius.circular(10))),
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
                      Text(_input, style: TextStyle(fontSize: 24, color: isWater ? Colors.white70 : AppColors.textDim)),
                      Text(_result, style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: isWater || isDark ? Colors.white : Colors.black)),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cellWidth = (constraints.maxWidth - 30) / 4; // Accounting for 3 x 10 cross spacing
                    final cellHeight = (constraints.maxHeight - 40) / 5; // Accounting for 4 x 10 main spacing
                    final aspectRatio = cellWidth / cellHeight;
                    
                    return GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: aspectRatio,
                     physics: const BouncingScrollPhysics(), // Allow scrolling to reach all buttons
                      shrinkWrap: true,
                      children: [
                    "C", "(", ")", "⌫",
                    "7", "8", "9", "÷",
                    "4", "5", "6", "x",
                    "1", "2", "3", "-",
                    "0", ".", "%", "+"
                  ].map<Widget>((label) {
                    bool isOp = ["÷", "x", "-", "+", "C", "⌫"].contains(label);
                    return LiquidPhysicsButton(
                      isWaterTheme: isWater,
                      onTap: () => _onPressed(label),
                      builder: (ctx, isPressed) => _glassButton(context, label, isWater, isDark, isOp, isPressed),
                    );
                  }).toList()..addAll([
                    const SizedBox(),
                    const SizedBox(),
                    const SizedBox(),
                    LiquidPhysicsButton(
                      isWaterTheme: isWater,
                      onTap: () => _onPressed("="),
                      builder: (ctx, isPressed) => _glassButton(context, "=", isWater, isDark, true, isPressed),
                    )
                  ]),
                );
                }
              )),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _calcAction("Expense", isWater ? Colors.white : AppColors.danger, isWater, () {
                      final valStr = _result != "Error" && _result.isNotEmpty ? _result : "0.0";
                      final val = double.tryParse(valStr) ?? 0.0;
                      if (val > 0) {
                        Navigator.pop(context);
                        showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddExpenseForm(existingExpense: Expense(amount: val, category: 'Shopping', date: DateTime.now(), note: 'From Calculator', lifeCostHours: 0)));
                      }
                  }),
                  _calcAction("Income", isWater ? Colors.white : AppColors.success, isWater, () {
                      final valStr = _result != "Error" && _result.isNotEmpty ? _result : "0.0";
                      final val = double.tryParse(valStr) ?? 0.0;
                      if (val > 0) {
                        Navigator.pop(context);
                        showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddIncomeForm(existingIncome: Income(amount: val, date: DateTime.now(), source: 'Calculator', note: '')));
                      }
                  }),
                  _calcAction("Savings", isWater ? Colors.white : AppColors.primary, isWater, () {
                      final valStr = _result != "Error" && _result.isNotEmpty ? _result : "0.0";
                      final val = double.tryParse(valStr) ?? 0.0;
                      if (val > 0) {
                        Navigator.pop(context);
                        showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddSavingForm(initialAmount: val));
                      }
                  }),
                  _calcAction("Bill", isWater ? Colors.white : AppColors.warning, isWater, () {
                      final valStr = _result != "Error" && _result.isNotEmpty ? _result : "0.0";
                      final val = double.tryParse(valStr) ?? 0.0;
                      if (val > 0) {
                        Navigator.pop(context);
                        showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddBillForm(existingBill: Bill(name: '', amount: val, dueDate: DateTime.now(), frequency: 'Monthly', category: 'Bills 📄')));
                      }
                  }),
                  _calcAction("Debt", isWater ? Colors.white : AppColors.info, isWater, () {
                      final valStr = _result != "Error" && _result.isNotEmpty ? _result : "0.0";
                      final val = double.tryParse(valStr) ?? 0.0;
                      if (val > 0) {
                        Navigator.pop(context);
                        showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => AddDebtForm(existingDebt: Debt(personName: '', amount: val, description: 'From Calculator', date: DateTime.now(), isOwedToMe: false)));
                      }
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (isWater) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return BackdropFilter(
              filter: ShaderService.getLiquidGlassFilter(
                intensity: s.refractionIntensity,
                tilt: Offset(_dragOffset.dx * 0.005, -_dragOffset.dy * 0.005),
                size: Size(constraints.maxWidth, constraints.maxHeight),
              ) ?? ImageFilter.blur(sigmaX: s.blurIntensity * 100, sigmaY: s.blurIntensity * 100),
              child: body,
            );
          }
        ),
      );
    }

    return body;
  }

  Widget _glassButton(BuildContext context, String label, bool isWater, bool isDark, bool isOp, bool isPressed) {
    final primaryColor = Theme.of(context).primaryColor;
    
    Color baseBg;
    Color textColor = Colors.white;
    if (["C", "(", ")", "⌫"].contains(label)) {
      baseBg = isDark ? Colors.grey[500]! : Colors.grey[300]!;
      textColor = isDark ? Colors.black : Colors.black87;
    } else if (["÷", "x", "-", "+", "="].contains(label)) {
      baseBg = Colors.orange;
    } else {
      baseBg = isDark ? Colors.grey[850]! : Colors.grey[200]!;
      if (!isDark) textColor = Colors.black;
    }
    
    // In water mode, make it beautifully translucent flat iOS style
    if (isWater) {
      baseBg = baseBg.withOpacity(isPressed ? 0.4 : 0.65);
    }

    Widget btnBody = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isWater ? baseBg : (isOp ? primaryColor.withOpacity(0.15) : Theme.of(context).cardColor),
      ),
      child: Center(
        child: Text(label, style: TextStyle(
          fontSize: 26, 
          fontWeight: FontWeight.w400, 
          color: isWater ? textColor : (isOp ? primaryColor : (isDark ? Colors.white : Colors.black))
        )),
      ),
    );

    if (isWater) {
      final pW = (MediaQuery.of(context).size.width - 48 - 30) / 4;
      final borderColor = isDark
          ? Colors.white.withOpacity(isPressed ? 0.6 : 0.25)
          : Colors.black.withOpacity(isPressed ? 0.25 : 0.08);
      return ClipOval(
        child: BackdropFilter(
          filter: ShaderService.getLiquidGlassFilter(
            intensity: 0.08,
            size: Size(pW, pW),
            shape: 1,
          ) ?? ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: baseBg.withOpacity(isPressed ? 0.35 : 0.15),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Center(
              child: Text(label, style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w400,
                color: textColor,
              )),
            ),
          ),
        ),
      );
    }

    return btnBody; // Return native flat body heavily backed by main turbulence backdrop
  }

  Widget _calcAction(String label, Color color, bool isWater, VoidCallback onTap) {
    return LiquidPhysicsButton(
      isWaterTheme: isWater,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(isWater ? 0.6 : 0.2), width: isWater ? 2.0 : 1.0),
        ),
        child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}

