import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedCard({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(duration: 500.ms, delay: (index * 100).ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }
}
