import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/settings_provider.dart';
import '../../theme/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final _name = TextEditingController();
  final _budget = TextEditingController();
  final _wage = TextEditingController();
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContent(),
                  ],
                ),
              ),
              _appleButton(_step == 2 ? "Unlock Nimbus" : "Continue", () {
                if (_step < 2) {
                  setState(() => _step++);
                } else {
                  if (_name.text.isEmpty) return;
                  context.read<SettingsProvider>().completeOnboarding(
                    _name.text,
                    double.tryParse(_budget.text) ?? 1000,
                    double.tryParse(_wage.text) ?? 20,
                    "USD", // Default currency
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
        const Text("Hello.", 
          style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, letterSpacing: -4, color: Colors.white))
          .animate().fadeIn(duration: 800.ms).slideY(begin: 0.2),
        const Text("I'm Nimbus. What should I call you?", 
          style: TextStyle(color: AppColors.textDim, fontSize: 18))
          .animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 50),
        TextField(
          controller: _name,
          autofocus: true,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          decoration: const InputDecoration(border: InputBorder.none, hintText: "Your Name", hintStyle: TextStyle(color: Colors.white10)),
        ),
      ]);
    }
    if (_step == 1) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Goals.", 
          style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, letterSpacing: -3, color: Colors.white))
          .animate().fadeIn().slideY(begin: 0.2),
        const Text("Set your monthly allowance target.", 
          style: TextStyle(color: AppColors.textDim, fontSize: 18)),
        const SizedBox(height: 50),
        TextField(
          controller: _budget,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          decoration: const InputDecoration(border: InputBorder.none, hintText: "0.00", hintStyle: TextStyle(color: Colors.white10)),
        ),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Value.", 
        style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, letterSpacing: -3, color: Colors.white))
        .animate().fadeIn().slideY(begin: 0.2),
      const Text("How much do you earn per hour?", 
        style: TextStyle(color: AppColors.textDim, fontSize: 18)),
      const SizedBox(height: 50),
      TextField(
        controller: _wage,
        autofocus: true,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        decoration: const InputDecoration(border: InputBorder.none, hintText: "0.00", hintStyle: TextStyle(color: Colors.white10)),
      ),
    ]);
  }

  Widget _appleButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ),
    );
  }
}