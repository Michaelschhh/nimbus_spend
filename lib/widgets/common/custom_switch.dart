import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../services/haptic_service.dart';
import '../../services/sound_service.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.light();
        SoundService.play('pop.mp3');
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value ? activeColor : (Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black12),
          border: Border.all(color: value ? activeColor : (Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.black12), width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              left: value ? 22 : 2,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                  ]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
