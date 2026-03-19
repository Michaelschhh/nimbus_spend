import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/badge.dart';
import '../../theme/colors.dart';
import '../../services/sound_service.dart';

class BadgeCelebration extends StatefulWidget {
  final BadgeModel badge;
  const BadgeCelebration({super.key, required this.badge});

  @override
  State<BadgeCelebration> createState() => _BadgeCelebrationState();
}

class _BadgeCelebrationState extends State<BadgeCelebration> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _confetti.play();
    SoundService.success();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [AppColors.gold, AppColors.primary, AppColors.success],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.badge.emoji, style: const TextStyle(fontSize: 80))
                  .animate().scale(curve: Curves.elasticOut, duration: 800.ms),
              const SizedBox(height: 20),
              const Text(
                "UNLOCKED",
                style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Text(widget.badge.name, style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(widget.badge.description, style: const TextStyle(color: AppColors.textDim)),
              const SizedBox(height: 50),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  decoration: BoxDecoration(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black), borderRadius: BorderRadius.circular(30)),
                  child: Text("Collect", style: TextStyle(color: Theme.of(context).scaffoldBackgroundColor, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}