import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';
import '../../utils/responsive.dart';
import 'apple_button.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  const TutorialOverlay({super.key, required this.onComplete});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _step = 0;

  final List<TutorialStep> _steps = [
    TutorialStep(
      title: "Welcome to Nimbus",
      body: "Your new command center for personal finance. Let's get you oriented.",
      icon: Icons.auto_awesome,
    ),
    TutorialStep(
      title: "The Allowance",
      body: "Track your monthly spending power. 'Allowance' is for daily life, 'Resources' are for total wealth.",
      icon: Icons.wallet,
    ),
    TutorialStep(
      title: "Smart Insights",
      body: "Our AI analyzes your funding sources to give you real-time pacing and velocity warnings.",
      icon: Icons.psychology,
    ),
    TutorialStep(
      title: "Ready to Start?",
      body: "Log your first transaction or deposit income in the Financial Hub to see the magic.",
      icon: Icons.rocket_launch,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = _steps[_step];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.15),
              ),
            ).animate().fadeIn(duration: 1.seconds).scale(begin: const Offset(0.5, 0.5)),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(current.icon, size: 80, color: Theme.of(context).primaryColor)
                      .animate(key: ValueKey(_step))
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: 40),
                  Text(
                    current.title,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
                    textAlign: TextAlign.center,
                  ).animate(key: ValueKey(_step + 10)).fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
                  const SizedBox(height: 16),
                  Text(
                    current.body,
                    style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                    textAlign: TextAlign.center,
                  ).animate(key: ValueKey(_step + 20)).fadeIn(delay: 400.ms),
                  const SizedBox(height: 60),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: AppleButton(
                      label: _step == _steps.length - 1 ? "Get Started" : "Continue",
                      onTap: () {
                        if (_step < _steps.length - 1) {
                          setState(() => _step++);
                        } else {
                          widget.onComplete();
                        }
                      },
                    ),
                  ).animate(key: ValueKey(_step + 30)).fadeIn(delay: 600.ms),
                  
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_steps.length, (index) => Container(
                      width: 8, height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _step == index ? Theme.of(context).primaryColor : Colors.white24,
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TutorialStep {
  final String title;
  final String body;
  final IconData icon;
  TutorialStep({required this.title, required this.body, required this.icon});
}
