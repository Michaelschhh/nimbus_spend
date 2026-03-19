import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../theme/colors.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  const TutorialOverlay({super.key, required this.onComplete});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _step = 0;

  final List<_TutorialStep> _steps = [
    const _TutorialStep(
      icon: LucideIcons.wallet,
      title: "Dashboard",
      body: "Your financial command center. See your available resources, monthly budget status, AI insights, and transactions grouped by category. Tap + to log a new expense. Long-press any transaction to hide it.",
      gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
    const _TutorialStep(
      icon: LucideIcons.arrowLeftRight,
      title: "Funding Sources",
      body: "When adding expenses or funding goals, choose where the money comes from:\n\n• Monthly Budget — counts against your allowance\n• Available Resources — deducts from your reserves\n• None — track it without any deductions",
      gradient: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
    ),
    const _TutorialStep(
      icon: LucideIcons.history,
      title: "History",
      body: "Every expense you log appears here chronologically. Swipe left to delete entries. Your complete spending history is always at your fingertips.",
      gradient: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    ),
    const _TutorialStep(
      icon: LucideIcons.pieChart,
      title: "Reports",
      body: "See beautiful pie and bar chart breakdowns of your spending by category. Each category has its own distinct color. You can share reports as images too.",
      gradient: [Color(0xFF10B981), Color(0xFF059669)],
    ),
    const _TutorialStep(
      icon: LucideIcons.briefcase,
      title: "Financial Hub",
      body: "Manage Bills, Debts, Subscriptions, Savings, and Financial Goals — all in one place. Each section tracks funding sources and payment progress automatically.",
      gradient: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    ),
    const _TutorialStep(
      icon: LucideIcons.brainCircuit,
      title: "AI Insights",
      body: "Nimbus AI analyzes your spending patterns and warns you about:\n\n• Large expenses relative to your budget\n• Weekend spending spikes\n• Subscription creep (>25% of budget)\n• Zero-spending streaks",
      gradient: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    ),
    const _TutorialStep(
      icon: LucideIcons.cloud,
      title: "Meet Nimbus",
      body: "Nimbus is your floating cloud mascot! He reacts to your financial health — happy when savings are strong, sad when you're over budget, and curious about your numbers. He'll also share 200+ finance tips. Toggle him on or off in Settings.",
      gradient: [Color(0xFF60A5FA), Color(0xFF34D399)],
    ),
    const _TutorialStep(
      icon: LucideIcons.eyeOff,
      title: "Hide Transactions",
      body: "Long-press any transaction or category group to hide it from your Dashboard. Tap the 'Hidden' badge to view all hidden items. Long-press a hidden item to restore it.",
      gradient: [Color(0xFF6B7280), Color(0xFF374151)],
    ),
    const _TutorialStep(
      icon: LucideIcons.palette,
      title: "Themes & Premium",
      body: "Customize Nimbus Spend with 10 gorgeous color themes — from Apple Blue to Rose Gold. Themes and Nimbus are available with the Pro upgrade.\n\nYou can also remove ads individually. Check out the Premium section in Settings!",
      gradient: [Color(0xFFDB2777), Color(0xFFF59E0B)],
    ),
    const _TutorialStep(
      icon: LucideIcons.settings,
      title: "Settings",
      body: "Update your name, monthly budget, hourly wage, currency, and available resources anytime. Toggle dark mode, sounds, Nimbus tips, and app lock. You can also remove ads or restore purchases here.",
      gradient: [Color(0xFF6B7280), Color(0xFF374151)],
    ),
    const _TutorialStep(
      icon: LucideIcons.zap,
      title: "Performance Mode",
      body: "Experience lags? Turn on Performance Mode in Settings to optimize Nimbus Spend for lower-end devices by disabling blurs and reducing heavy animations.",
      gradient: [Color(0xFFF59E0B), Color(0xFFFACC15)],
    ),
  ];


  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      widget.onComplete();
    }
  }

  void _prev() {
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    return Scaffold(
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Progress indicators
              Row(
                children: List.generate(_steps.length, (i) => Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= _step ? Theme.of(context).primaryColor : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 15),
              // Skip button
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: widget.onComplete,
                  child: const Text("Skip", style: TextStyle(color: AppColors.textDim, fontSize: 14)),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: _buildCard(step),
                ),
              ),
              // Navigation
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: GestureDetector(
                          onTap: _prev,
                          child: Container(
                            height: 60,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.1)),
                            ),
                            child: Center(
                              child: Text("Back", style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87), fontWeight: FontWeight.w600, fontSize: 16)),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      flex: _step == 0 ? 1 : 2,
                      child: GestureDetector(
                        onTap: _next,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(
                              _step == _steps.length - 1 ? "Get Started" : "Next",
                              style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(_TutorialStep step) {
    return Column(
      key: ValueKey(_step),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon circle with gradient
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: step.gradient),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: step.gradient.first.withOpacity(0.3), blurRadius: 30, spreadRadius: 5),
            ],
          ),
          child: Icon(step.icon, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), size: 42),
        ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
        const SizedBox(height: 40),
        Text(step.title,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), letterSpacing: -1),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.15),
        const SizedBox(height: 20),
        // Glass card body
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.07),
                    (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(0.08)),
              ),
              child: Text(step.body,
                style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87), fontSize: 15, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),
      ],
    );
  }
}

class _TutorialStep {
  final IconData icon;
  final String title;
  final String body;
  final List<Color> gradient;

  const _TutorialStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.gradient,
  });
}
