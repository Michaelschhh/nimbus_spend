import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/common/custom_switch.dart';
import '../../widgets/common/apple_button.dart';
import '../../services/sound_service.dart';

class SalarySettingsScreen extends StatefulWidget {
  const SalarySettingsScreen({super.key});

  @override
  State<SalarySettingsScreen> createState() => _SalarySettingsScreenState();
}

class _SalarySettingsScreenState extends State<SalarySettingsScreen> {
  late bool _isSalaryEarner;
  late double _salaryAmount;
  late String _salaryFrequency;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    _isSalaryEarner = settings.isSalaryEarner;
    _salaryAmount = settings.salaryAmount;
    _salaryFrequency = settings.salaryFrequency;
    _amountController.text = _salaryAmount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(LucideIcons.arrowLeft, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), size: 22),
                ),
                const SizedBox(width: 16),
                Text("Salary", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), letterSpacing: -1)),
              ]),
              const SizedBox(height: 30),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  Icon(LucideIcons.briefcase, color: Theme.of(context).primaryColor, size: 18),
                  const SizedBox(width: 14),
                  Expanded(child: Text("Salary Earning", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)))),
                  CustomSwitch(
                    value: _isSalaryEarner,
                    onChanged: (val) {
                      setState(() => _isSalaryEarner = val);
                      SoundService.tap();
                    },
                  ),
                ]),
              ),
              
              const SizedBox(height: 20),
              
              if (_isSalaryEarner) ...[
                const Text("CONFIGURATION", style: TextStyle(color: AppColors.textDim, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Monthly Paycheck", style: TextStyle(color: AppColors.textDim, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
                        onChanged: (v) => setState(() => _salaryAmount = double.tryParse(v) ?? 0),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "0.00",
                          hintStyle: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    Icon(LucideIcons.calendar, color: Theme.of(context).primaryColor, size: 18),
                    const SizedBox(width: 14),
                    Expanded(child: Text("Frequency", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)))),
                    DropdownButton<String>(
                      value: _salaryFrequency,
                      dropdownColor: Theme.of(context).cardColor,
                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                      underline: const SizedBox(),
                      items: ['Monthly'].map((f) => DropdownMenuItem(value: f, child: Text("Per $f"))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _salaryFrequency = v);
                      },
                    ),
                  ]),
                ),
              ],
              
              const Spacer(),
              AppleButton(
                label: "Save Salary Settings",
                onTap: () {
                  context.read<SettingsProvider>().updateSalarySettings(_isSalaryEarner, _salaryAmount, _salaryFrequency);
                  SoundService.success();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
