import 'dart:ui';
import 'package:flutter/material.dart';

class CursiveWelcome extends StatefulWidget {
  const CursiveWelcome({super.key});

  @override
  State<CursiveWelcome> createState() => _CursiveWelcomeState();
}

class _CursiveWelcomeState extends State<CursiveWelcome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(300, 100),
          painter: WelcomePainter(_controller.value, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
        );
      },
    );
  }
}

class WelcomePainter extends CustomPainter {
  final double progress;
  final Color color;
  WelcomePainter(this.progress, {required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path path = Path();

    // "W"
    path.moveTo(size.width * 0.1, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.9,
      size.width * 0.2,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.9,
      size.width * 0.3,
      size.height * 0.4,
    );

    // "e"
    path.relativeQuadraticBezierTo(10, -20, 20, -5);
    path.relativeQuadraticBezierTo(5, 15, -15, 15);

    // "l"
    path.relativeQuadraticBezierTo(20, -40, 10, -50);
    path.relativeQuadraticBezierTo(-5, 10, 5, 50);

    // "c"
    path.relativeQuadraticBezierTo(15, -15, 20, 0);
    path.relativeQuadraticBezierTo(5, 15, -15, 10);

    // "o" (Replaces the oval error)
    path.relativeQuadraticBezierTo(10, -20, 20, 0);
    path.relativeQuadraticBezierTo(-10, 20, -20, 0);

    // Animate drawing
    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      Path extract = pathMetric.extractPath(0.0, pathMetric.length * progress);
      canvas.drawPath(extract, paint);
    }
  }

  @override
  bool shouldRepaint(WelcomePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
