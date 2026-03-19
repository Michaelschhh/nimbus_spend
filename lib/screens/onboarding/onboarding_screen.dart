import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';
import '../../widgets/common/currency_picker_modal.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _name = TextEditingController();
  final _budget = TextEditingController();
  final _wage = TextEditingController();
  final _resources = TextEditingController();
  String _selectedCurrency = 'USD';
  bool _isSalaryEarner = false;
  final _salaryAmount = TextEditingController();
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: SingleChildScrollView(
                    key: ValueKey<int>(_step),
                    child: _buildContent(),
                  ),
                ),
              ),
              _appleButton(_step == 4 ? "Unlock Nimbus" : "Continue", () {
                if (_step < 4) {
                  setState(() => _step++);
                } else {
                  if (_name.text.isEmpty) return;
                  context.read<SettingsProvider>().completeOnboarding(
                    _name.text,
                    double.tryParse(_budget.text) ?? 1000,
                    double.tryParse(_wage.text) ?? 20,
                    _selectedCurrency,
                    availableResources: double.tryParse(_resources.text),
                    isSalaryEarner: _isSalaryEarner,
                    salaryAmount: double.tryParse(_salaryAmount.text),
                  );
                }
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_step == 0) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 80),
        Text("Hello.",
                style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, letterSpacing: -4, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)))
            .animate().fadeIn(duration: 800.ms).slideY(begin: 0.2),
        const Text("I'm Nimbus. What should I call you?",
                style: TextStyle(color: AppColors.textDim, fontSize: 18))
            .animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 50),
        TextField(
          controller: _name,
          autofocus: true,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
          decoration: InputDecoration(
              border: InputBorder.none, hintText: "Your Name", hintStyle: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12))),
        ),
      ]);
    }
    if (_step == 1) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Goals.",
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, letterSpacing: -3, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)))
            .animate().fadeIn().slideY(begin: 0.2),
        const Text("Set your monthly allowance target.",
            style: TextStyle(color: AppColors.textDim, fontSize: 18)),
        const SizedBox(height: 50),
        TextField(
          controller: _budget,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
          decoration: InputDecoration(
              border: InputBorder.none, hintText: "0.00", hintStyle: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12))),
        ),
      ]);
    }
    if (_step == 2) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Value.",
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, letterSpacing: -3, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)))
            .animate().fadeIn().slideY(begin: 0.2),
        const Text("How much do you earn per hour?",
            style: TextStyle(color: AppColors.textDim, fontSize: 18)),
        const SizedBox(height: 50),
        TextField(
          controller: _wage,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
          decoration: InputDecoration(
              border: InputBorder.none, hintText: "0.00", hintStyle: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12))),
        ),
        const SizedBox(height: 30),
        const Text("Currency", style: TextStyle(color: AppColors.textDim, fontSize: 18)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
              builder: (context) => CurrencyPickerModal(onSelect: (code) {
                setState(() => _selectedCurrency = code);
                Navigator.pop(context);
              }),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedCurrency,
                    style: TextStyle(fontSize: 20, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
                const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ]);
    }
    if (_step == 3) {
      // Step 3: Available Resources
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Reserves.",
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, letterSpacing: -3, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)))
            .animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 8),
        const Text("How much do you have available outside your monthly budget?",
            style: TextStyle(color: AppColors.textDim, fontSize: 18)),
        const SizedBox(height: 50),
        TextField(
          controller: _resources,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
          decoration: InputDecoration(
              border: InputBorder.none, hintText: "0.00", hintStyle: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12))),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primary.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("What are Available Resources?",
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Text(
                "This is the total value you have outside your monthly budget — savings, emergency funds, or liquid assets.\n\nWhen you pay bills, settle debts, or fund goals, you can choose to pull from this pool instead of your monthly allowance.\n\nYou can always update this in Settings.",
                style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87), fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      ]);
    }
    if (_step == 4) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Salary.",
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, letterSpacing: -3, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)))
            .animate().fadeIn().slideY(begin: 0.2),
        const Text("Are you a salary earner?",
            style: TextStyle(color: AppColors.textDim, fontSize: 18)),
        const SizedBox(height: 30),
        
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _isSalaryEarner = true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: _isSalaryEarner ? AppColors.primary : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text("Yes, I am", style: TextStyle(color: _isSalaryEarner ? Theme.of(context).scaffoldBackgroundColor : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
             GestureDetector(
              onTap: () => setState(() => _isSalaryEarner = false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: !_isSalaryEarner ? AppColors.textDim : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text("No, I'm not", style: TextStyle(color: !_isSalaryEarner ? Theme.of(context).scaffoldBackgroundColor : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        
        if (_isSalaryEarner) ...[
          const SizedBox(height: 50),
          const Text("Monthly Paycheck", style: TextStyle(color: AppColors.textDim, fontSize: 18)),
          TextField(
            controller: _salaryAmount,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            decoration: InputDecoration(
                border: InputBorder.none, hintText: "0.00", hintStyle: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12))),
          ),
        ],
      ]);
    }
    return const SizedBox();
  }

  Widget _appleButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        width: double.infinity,
        decoration: BoxDecoration(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), borderRadius: BorderRadius.circular(20)),
        child: Center(
          child: Text(label,
              style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    );
  }
}