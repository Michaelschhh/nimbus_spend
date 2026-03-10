import 'package:flutter/material.dart';
import '../../services/sound_service.dart';
import '../../services/haptic_service.dart';

class AppleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color bgColor;
  final Color textColor;
  final bool isDestructive;

  const AppleButton({
    super.key,
    required this.label,
    required this.onTap,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.light();
        SoundService.play('pop.mp3'); // Ensure pop.mp3 is in assets/sounds
        onTap();
      },
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDestructive ? Colors.transparent : bgColor,
          borderRadius: BorderRadius.circular(16),
          border: isDestructive ? Border.all(color: Colors.redAccent.withOpacity(0.5)) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isDestructive ? Colors.redAccent : textColor,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              decoration: TextDecoration.none, // Removes yellow lines
            ),
          ),
        ),
      ),
    );
  }
}