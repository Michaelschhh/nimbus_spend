import 'package:flutter/material.dart';
import 'dart:ui';
import '../../utils/formatters.dart';
import '../../theme/colors.dart';
import '../../services/shader_service.dart';
import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';
import '../common/life_cost_badge.dart';

class DailyOverviewCard extends StatefulWidget {
  final double spentToday;
  final double lifeHours;
  final String currency;

  const DailyOverviewCard({
    super.key,
    required this.spentToday,
    required this.lifeHours,
    required this.currency,
  });

  @override
  State<DailyOverviewCard> createState() => _DailyOverviewCardState();
}

class _DailyOverviewCardState extends State<DailyOverviewCard> {
  double _tiltX = 0;
  double _tiltY = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>().settings;
    return MouseRegion(
      onEnter: (_) {}, // For hover if needed
      child: GestureDetector(
        onPanUpdate: (d) => setState(() {
          _tiltY += d.delta.dx * 0.01;
          _tiltX -= d.delta.dy * 0.01;
          _tiltX = _tiltX.clamp(-0.15, 0.15);
          _tiltY = _tiltY.clamp(-0.15, 0.15);
        }),
        onPanEnd: (_) => setState(() {
          _tiltX = 0; _tiltY = 0;
        }),
        child: AnimatedRotation(
          duration: const Duration(milliseconds: 200),
          turns: 0,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_tiltX)
              ..rotateY(_tiltY),
            alignment: Alignment.center,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ShaderService.getLiquidGlassFilter(
                    intensity: s.refractionIntensity,
                    tilt: Offset(_tiltY * 0.1, -_tiltX * 0.1), // Dynamic tilt
                  ) ?? ImageFilter.blur(sigmaX: s.blurIntensity * 100, sigmaY: s.blurIntensity * 100),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.35),
                          Theme.of(context).colorScheme.secondary.withOpacity(0.45),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 7.0, // Thick glass rim
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Spend",
                          style: TextStyle(
                            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Formatters.currency(widget.spentToday, widget.currency),
                          style: TextStyle(
                            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LifeCostBadge(hours: widget.lifeHours, isLarge: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
