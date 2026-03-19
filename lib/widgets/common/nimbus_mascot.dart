import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/expense_provider.dart';
import '../../utils/nimbus_tips.dart';
import '../../utils/responsive.dart';


/// Nimbus the Cloud Mascot — a physics-based interactive pet for Pro users.
/// Converted from HTML/SVG/JS to native Flutter.
class NimbusMascot extends StatefulWidget {
  static final GlobalKey<NimbusMascotState> mascotKey = GlobalKey<NimbusMascotState>();
  const NimbusMascot({super.key});

  @override
  State<NimbusMascot> createState() => NimbusMascotState();
}

enum NimbusEmo { idle, happy, excited, surprised, sad, sleep, curious }

class NimbusMascotState extends State<NimbusMascot> with SingleTickerProviderStateMixin {
  // Position & velocity
  double px = 100, py = 200;
  double svx = 0, svy = 0; // state velocity (wandering)
  double pvx = 0, pvy = 0; // physics velocity (thrown)

  // Squash & stretch
  double sqX = 1, sqY = 1, sqV = 0;

  // State
  bool held = false, dragged = false, flight = false;
  NimbusEmo emo = NimbusEmo.idle;
  String? bubbleText;
  int bubbleTick = 0;
  int taps = 0;
  int idleTicks = 0;
  int lastInteractionTick = 0;
  int _lastTipTick = 0; // Track when we last showed a tip

  // Wander & Curiosity
  double wAngle = 0;
  final Random rng = Random();
  Offset? curiosityPos;
  int curiosityTick = 0;
  double speedMult = 1.0;

  // Drag tracking
  double ox = 0, oy = 0;
  final List<_TrailPoint> trail = [];

  // Opacity & Scrolling
  double _opacity = 1.0;
  int _scrollTicks = 0;

  // Timing
  late Ticker _ticker;
  int _tickCount = 0;
  int _emoEndTick = 0;
  int _decideAtTick = 0;

  double mw = 70, mh = 56;
  static const double grav = 0.34, pdrag = 0.993, bounce = 0.5, fric = 0.86;

  @override
  void initState() {
    super.initState();
    wAngle = rng.nextDouble() * pi * 2;
    _ticker = createTicker(_onTick)..start();
    _decideAtTick = 60;
    lastInteractionTick = 0;
    
    // Initial size setup (will update on build for safety)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          mw = Responsive.mascotSize(context, base: 70);
          mh = Responsive.mascotSize(context, base: 56);
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double get screenW => MediaQuery.of(context).size.width;
  double get screenH => MediaQuery.of(context).size.height;
  double get floor => screenH - 130 - mh; // above nav bar

  void _onTick(Duration elapsed) {
    _tickCount++;
    setState(() {
      // Bubble timeout
      final sProv = context.read<SettingsProvider>();
    final isPerf = sProv.settings.performanceModeEnabled;

    if (bubbleTick > 0) {
      bubbleTick--;
      if (bubbleTick == 0) bubbleText = null;
    }

    if (held) {
      if (!isPerf) trail.add(_TrailPoint(px + mw / 2, py + mh / 2, DateTime.now().millisecondsSinceEpoch));
    }



    if (!isPerf && trail.length > 20) trail.removeAt(0);
    if (isPerf && trail.isNotEmpty) trail.clear();
      double targetOp = 1.0;
      if (_scrollTicks > 0) {
        targetOp = 0.2; // Very transparent while scrolling
        _scrollTicks--; // Ensure the ticker unwinds correctly
      } else if (emo == NimbusEmo.sleep) {
        targetOp = 0.4; // Opaque enough to see through (transparent)
      }
      _opacity += (targetOp - _opacity) * 0.12; // Smooth transition

      // Emo timeout
      if (_emoEndTick > 0 && _tickCount >= _emoEndTick) {
        emo = NimbusEmo.idle;
        _emoEndTick = 0;
      }

      // Idle sleep check - now 2 minutes (7200 ticks at 60fps)
      if (!held && !flight && emo == NimbusEmo.idle) {
        idleTicks++;
        if (idleTicks > 7200) {
          emo = NimbusEmo.sleep;
          svx = 0; svy = 0;
          idleTicks = 0;
          curiosityPos = null;
        }
      }

      // Emotional Neglect - if not played with for 5 mins (18000 ticks)
      if (emo == NimbusEmo.sleep && (_tickCount - lastInteractionTick) > 18000) {
        if (_tickCount % 3600 == 0) { // Check every minute while asleep
          if (rng.nextDouble() < 0.3) {
            _setEmo(NimbusEmo.sad, 300); // Wake up sad
            _showBubble("I'm lonely... ☁️");
          }
        }
      }

      if (!held) {
        if (flight) {
          _physicsStep();
        } else if (emo == NimbusEmo.sleep) {
          // Subtle floating while sleeping
          py += sin(_tickCount * 0.05) * 0.2;
        } else {
          _wanderStep();
          // Only run _decide at scheduled intervals for movement decisions
          if (_tickCount >= _decideAtTick) _decide();
        }
      }

      // Anti-freeze: if curiosity has been stuck for too long, clear it
      if (curiosityPos != null && curiosityTick <= 0) {
        curiosityPos = null;
      }

      // Speed multiplier decay
      if (speedMult > 1.0) speedMult -= 0.005;
      if (speedMult < 1.0) speedMult = 1.0;

      // Squash recovery
      if (!isPerf && ((sqX - 1).abs() > 0.001 || (sqY - 1).abs() > 0.001)) {
        sqX += (1 - sqX) * 0.17 + sqV;
        sqY += (1 - sqY) * 0.17 - sqV;
        sqV *= 0.7;
      } else if (isPerf) { // If performance mode, snap back instantly
        sqX = 1; sqY = 1; sqV = 0;
      } else {
        sqX = 1; sqY = 1; sqV = 0;
      }
    });
  }

  void _physicsStep() {
    pvy += grav;
    pvx *= pdrag; pvy *= pdrag;
    px += pvx; py += pvy;

    if (px < 0) { px = 0; pvx = pvx.abs() * bounce; _squash(false); }
    if (px > screenW - mw) { px = screenW - mw; pvx = -pvx.abs() * bounce; _squash(false); }
    if (py < 0) { py = 0; pvy = pvy.abs() * bounce * 0.5; _squash(true); }
    if (py >= floor) {
      py = floor;
      final imp = pvy.abs();
      if (imp > 2.5) {
        _squash(true);
        pvy = -imp * bounce;
        pvx *= fric;
        _setEmo(NimbusEmo.happy, 54);
      } else {
        pvy = 0;
        if (pvx.abs() < 0.4) {
          pvx = 0; flight = false; svx = 0; svy = 0;
          emo = NimbusEmo.idle;
          _decide();
        } else {
          pvx *= fric;
        }
      }
    }
  }

  void _wanderStep() {
    // Repel from edges
    final cx = px + mw / 2, cy = py + mh / 2;
    if (cx < 40) svx += (40 - cx) * 0.03;
    if (cx > screenW - 40) svx -= (cx - (screenW - 40)) * 0.03;
    if (cy < 80) svy += (80 - cy) * 0.03;
    if (cy > floor - 40) svy -= (cy - (floor - 40)) * 0.03;

    if (curiosityPos != null) {
      // Fly towards curiosity point
      _seek(curiosityPos!.dx, curiosityPos!.dy, 0.15, 2.2 * speedMult);
      if (curiosityTick > 0) {
        curiosityTick--;
        if (curiosityTick <= 0) curiosityPos = null;
      }
    } else {
      // Gentle wander
      wAngle += (rng.nextDouble() - 0.5) * 0.15;
      final hx = cos(wAngle), hy = sin(wAngle);
      final tx = cx + hx * 120 + cos(wAngle) * 40;
      final ty = cy + hy * 120 + sin(wAngle) * 40;
      _seek(tx, ty, 0.12, 2.2);
    }

    svx *= 0.96; svy *= 0.96;
    px += svx; py += svy;

    px = px.clamp(0.0, screenW - mw);
    py = py.clamp(20.0, floor);
  }

  void _seek(double tx, double ty, double f, double maxSpd) {
    final dx = tx - (px + mw / 2), dy = ty - (py + mh / 2);
    final d = sqrt(dx * dx + dy * dy);
    if (d < 5.0) return; // Arrived
    final sp = maxSpd;
    final t = d < 90 ? sp * (d / 90) : sp;
    final dsvx = (dx / d) * t - svx, dsvy = (dy / d) * t - svy;
    final m = sqrt(dsvx * dsvx + dsvy * dsvy);
    if (m > 0) {
      svx += (dsvx / m) * min(f, m);
      svy += (dsvy / m) * min(f, m);
    }
    final v = sqrt(svx * svx + svy * svy);
    if (v > sp) { svx = svx / v * sp; svy = svy / v * sp; }
  }

  void _squash(bool vertical) {
    final s = context.read<SettingsProvider>().settings;
    if (s.performanceModeEnabled) return; // Skip squash/stretch in performance mode
    if (vertical) { sqX = 1.42; sqY = 0.68; sqV = 0.012; }
    else { sqX = 0.7; sqY = 1.4; sqV = -0.012; }
    _setEmo(NimbusEmo.surprised, 25);
  }

  void _setEmo(NimbusEmo e, [int? durationTicks]) {
    emo = e;
    idleTicks = 0;
    if (durationTicks != null) {
      _emoEndTick = _tickCount + durationTicks;
    } else {
      _emoEndTick = 0;
    }
  }

  void _decide() {
    if (held || flight || emo == NimbusEmo.sleep || !mounted) return;

    final sProv = context.read<SettingsProvider>();
    final eProv = context.read<ExpenseProvider>();

    // Movement decisions happen frequently (every 3-8 seconds)
    // Randomly get curious about numbers/labels on screen
    if (rng.nextDouble() < 0.15) {
      final tx = 40 + rng.nextDouble() * (screenW - 80);
      final ty = 100 + rng.nextDouble() * (floor - 120);
      curiosityPos = Offset(tx, ty);
      curiosityTick = 180 + rng.nextInt(300);
      _setEmo(NimbusEmo.curious, 60);
    }

    // Speech/tip decisions only every 7-15 minutes (25200-54000 ticks at 60fps)
    final ticksSinceLastTip = _tickCount - _lastTipTick;
    final minTipInterval = 25200; // 7 minutes
    if (ticksSinceLastTip >= minTipInterval && sProv.settings.mascotTipsEnabled) {
      final budgetLeft = sProv.settings.monthlyBudget - eProv.totalSpentThisMonth;
      final hasExpenses = eProv.expenses.isNotEmpty;
      final hasSavings = sProv.settings.availableResources > 0 && sProv.settings.monthlyBudget > 0;
      
      if (budgetLeft < 0 && hasExpenses) {
        _setEmo(NimbusEmo.sad, 120);
        _showBubble("We're over budget this month... Let's be careful! 😥", 300);
        _lastTipTick = _tickCount;
      } else if (hasSavings && sProv.settings.availableResources > sProv.settings.monthlyBudget * 3) {
        _setEmo(NimbusEmo.happy, 120);
        final saveMsg = [
          "Your available resources are looking strong! 🌟",
          "Great reserves! Keep it up! 💪",
          "You have a solid financial cushion! ☁️",
        ];
        _showBubble(saveMsg[rng.nextInt(saveMsg.length)], 300);
        _lastTipTick = _tickCount;
      } else if (rng.nextDouble() < 0.6) {
        final tip = NimbusTips.tips[rng.nextInt(NimbusTips.tips.length)];
        _setEmo(NimbusEmo.happy, 120);
        _showBubble(tip, 360); // ~6 seconds to read
        _lastTipTick = _tickCount;
      }
    }

    // Schedule next movement decision (3-8 seconds)
    _decideAtTick = _tickCount + 180 + rng.nextInt(300);
  }

  void _showBubble(String text, [int duration = 150]) {
    bubbleText = text;
    bubbleTick = duration;
  }

  double _getBubbleLeft() {
    // Attempt to center bubble over Nimbus
    double left = (px + mw / 2 - 110); // 220 is max width / 2
    // Clamp to screen edges
    return left.clamp(12.0, screenW - 232.0); // 220 + padding
  }

  // --- Public API for app reactions ---
  void react(String event) {
    lastInteractionTick = _tickCount;
    if (emo == NimbusEmo.sleep) {
      _setEmo(NimbusEmo.surprised, 42);
    }
    if (event == 'spend') {
      _setEmo(NimbusEmo.sad, 180);
    } else if (event == 'earn') {
      _setEmo(NimbusEmo.excited, 150);
    } else if (event == 'excited') {
      _setEmo(NimbusEmo.excited, 130);
      sqX = 1.22; sqY = 0.8; sqV = 0;
    }
  }

  void tapAt(Offset pos) {
    lastInteractionTick = _tickCount;
    if (emo == NimbusEmo.sleep) {
      _setEmo(NimbusEmo.surprised, 40);
    }
    curiosityPos = pos;
    curiosityTick = 120;
    speedMult = 1.2; // 20% faster
    _setEmo(NimbusEmo.surprised, 30);
  }

  void wakeUp() {
    if (emo == NimbusEmo.sleep) {
      _setEmo(NimbusEmo.happy, 120);
      _showBubble("I'm awake! ✨");
    }
    lastInteractionTick = _tickCount;
  }

  void onUserScroll() {
    _scrollTicks = 40; // Stay transparent for ~0.6s
  }

  // --- Gesture handlers ---
  void _onPanStart(DragStartDetails details) {
    held = true; dragged = false; flight = false;
    lastInteractionTick = _tickCount;
    ox = details.globalPosition.dx - px;
    oy = details.globalPosition.dy - py;
    trail.clear();
    final s = context.read<SettingsProvider>().settings;
    if (!s.performanceModeEnabled) { // Only squash/stretch if not in performance mode
      sqX = 0.9; sqY = 1.12; sqV = 0;
    }
    _setEmo(NimbusEmo.surprised, 17);
    if (emo == NimbusEmo.sleep) {
      _setEmo(NimbusEmo.surprised, 42);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!held) return;
    dragged = true;
    px = (details.globalPosition.dx - ox).clamp(0, screenW - mw);
    py = (details.globalPosition.dy - oy).clamp(0, floor);
    final now = DateTime.now().millisecondsSinceEpoch;
    final s = context.read<SettingsProvider>().settings;
    if (!s.performanceModeEnabled) {
      trail.add(_TrailPoint(details.globalPosition.dx, details.globalPosition.dy, now));
      while (trail.length > 1 && now - trail.first.t > 140) trail.removeAt(0);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (!held) return;
    held = false;

    if (!dragged) {
      // Tap
      taps++;
      final s = context.read<SettingsProvider>().settings;
      if (!s.performanceModeEnabled) { // Only squash/stretch if not in performance mode
        sqX = 1.18; sqY = 0.84; sqV = 0;
      }
      _setEmo(NimbusEmo.happy, 90);

      if (taps % 5 == 0) {
        final msgs = ['Hey! ☁️', 'Hi there! 🌤️', "I'm Nimbus! 💙", 'Boop! 😄', '✨💫'];
        _showBubble(msgs[rng.nextInt(msgs.length)]);
        _setEmo(NimbusEmo.excited, 110);
      }
      svx = 0; svy = 0;
      _decide();
      return;
    }

    // Throw
    if (trail.length >= 2) {
      final a = trail.first, b = trail.last;
      final dt = max(12, b.t - a.t).toDouble();
      pvx = (b.x - a.x) / dt * 14;
      pvy = (b.y - a.y) / dt * 14;
      final sp = sqrt(pvx * pvx + pvy * pvy);
      if (sp > 26) { pvx = pvx / sp * 26; pvy = pvy / sp * 26; }
    } else {
      pvx = 0; pvy = 0;
    }
    svx = 0; svy = 0;
    if (sqrt(pvx * pvx + pvy * pvy) < 1.5 && py >= floor - 2) {
      flight = false;
      emo = NimbusEmo.idle;
      _decide();
    } else {
      flight = true;
      _setEmo(NimbusEmo.surprised, 21);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic size check to ensure responsiveness during orientation changes etc.
    final targetMw = Responsive.mascotSize(context, base: 70);
    final targetMh = Responsive.mascotSize(context, base: 56);
    if (mw != targetMw || mh != targetMh) {
      // Defer state update to next frame to avoid build-time errors
      Future.microtask(() {
        if (mounted) setState(() { mw = targetMw; mh = targetMh; });
      });
    }

    return Opacity(
      opacity: _opacity.clamp(0, 1),
      child: Stack(
        children: [
        // Speech bubble — clamped to screen with theme awareness
        if (bubbleText != null)
          Positioned(
            left: _getBubbleLeft(),
            top: max(4, py - (Responsive.isTablet(context) ? 80 : 58)),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: Responsive.isTablet(context) ? 350 : (screenW - 24)),
              child: _SpeechBubble(text: bubbleText!, isDark: Theme.of(context).brightness == Brightness.dark, primaryColor: Theme.of(context).primaryColor),
            ),
          ),
        // Cloud body
        Positioned(
          left: px,
          top: py,
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()..scale(sqX, sqY),
              child: SizedBox(
                width: mw,
                height: mh,
                child: CustomPaint(
                  painter: _NimbusCloudPainter(emo: emo),
                ),
              ),
            ),
          ),
        ),
        // Trail rendering
        Builder(
          builder: (context) {
            final s = context.read<SettingsProvider>().settings;
            if (s.performanceModeEnabled) return const SizedBox.shrink();
            
            return IgnorePointer(
              child: CustomPaint(
                size: Size(screenW, screenH),
                painter: _TrailPainter(trail),
              ),
            );
          },
        ),
      ],
    ),
  );
}
}

class _TrailPoint {
  final double x, y;
  final int t;
  _TrailPoint(this.x, this.y, this.t);
}

class _TrailPainter extends CustomPainter {
  final List<_TrailPoint> points;
  _TrailPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final age = now - p1.t;
      if (age > 140) continue;
      paint.color = Colors.white.withOpacity(0.3 * (1 - age / 140));
      canvas.drawLine(Offset(p1.x, p1.y), Offset(p2.x, p2.y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPainter old) => true;
}


class _SpeechBubble extends StatelessWidget {
  final String text;
  final bool isDark;
  final Color primaryColor;
  const _SpeechBubble({required this.text, required this.isDark, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? primaryColor.withOpacity(0.3) : const Color(0xFFC8E4F8);
    final textColor = isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF3A6EA8);
    final shadowColor = isDark ? Colors.black.withOpacity(0.3) : const Color(0xFF508CD2).withOpacity(0.15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      constraints: const BoxConstraints(maxWidth: 220),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [BoxShadow(color: shadowColor, blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 12, decoration: TextDecoration.none, height: 1.3), maxLines: 4, overflow: TextOverflow.ellipsis),
    );
  }
}

/// Custom painter that draws the Nimbus cloud character with face expressions.
class _NimbusCloudPainter extends CustomPainter {
  final NimbusEmo emo;
  _NimbusCloudPainter({required this.emo});

  @override
  void paint(Canvas canvas, Size size) {
    final sw = size.width, sh = size.height;

    // Scale factors from 120x100 SVG viewbox to actual size
    final sx = sw / 120, sy = sh / 100;

    // Cloud body fill
    final cloudPath = _buildCloudPath(sx, sy);
    
    // Main gradient fill
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.16, -0.56),
        radius: 0.72,
        colors: [
          Colors.white,
          const Color(0xFFF2F9FF),
          const Color(0xFFC6DFF2),
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, sw, sh));
    canvas.drawPath(cloudPath, bodyPaint);

    // Shadow gradient overlay
    final shadowPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x005A8CBA), Color(0x335A8CBA)], // Increased from 0x17
        stops: [0.2, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, sw, sh));
    canvas.drawPath(cloudPath, shadowPaint);

    // Shine highlight
    final shinePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.32, -0.68),
        radius: 0.42,
        colors: [Colors.white.withOpacity(0.82), Colors.white.withOpacity(0)],
      ).createShader(Rect.fromLTWH(0, 0, sw, sh));
    canvas.drawPath(cloudPath, shinePaint);

    // --- Face ---
    final facePaint = Paint()..color = const Color(0xFF1C3048);
    final eyeHighlight = Paint()..color = Colors.white;

    if (emo == NimbusEmo.sleep) {
      // Closed eyes (arcs)
      final closedEyePaint = Paint()
        ..color = const Color(0xFF1C3048)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.3 * sx
        ..strokeCap = StrokeCap.round;
      
      final leftArc = Path()
        ..moveTo(43 * sx, 67 * sy)
        ..quadraticBezierTo(48 * sx, 63 * sy, 53 * sx, 67 * sy);
      canvas.drawPath(leftArc, closedEyePaint);

      final rightArc = Path()
        ..moveTo(67 * sx, 67 * sy)
        ..quadraticBezierTo(72 * sx, 63 * sy, 77 * sx, 67 * sy);
      canvas.drawPath(rightArc, closedEyePaint);

      // Z's
      final zPaint = TextPainter(textDirection: TextDirection.ltr);
      for (var i = 0; i < 3; i++) {
        zPaint.text = TextSpan(
          text: i == 1 ? 'Z' : 'z',
          style: TextStyle(color: const Color(0xFF90B8D8), fontSize: (9.0 + i * 3) * sx, fontWeight: FontWeight.w900, decoration: TextDecoration.none),
        );
        zPaint.layout();
        zPaint.paint(canvas, Offset((82 + i * 7) * sx, (40 - i * 9) * sy));
      }
    } else {
      // Open eyes
      canvas.drawCircle(Offset(48 * sx, 66 * sy), 7 * sx, facePaint);
      canvas.drawCircle(Offset(45.2 * sx, 63.2 * sy), 2.5 * sx, eyeHighlight);
      canvas.drawCircle(Offset(50.5 * sx, 68.2 * sy), 1.1 * sx, Paint()..color = Colors.white.withOpacity(0.5));

      canvas.drawCircle(Offset(72 * sx, 66 * sy), 7 * sx, facePaint);
      canvas.drawCircle(Offset(69.2 * sx, 63.2 * sy), 2.5 * sx, eyeHighlight);
      canvas.drawCircle(Offset(74.5 * sx, 68.2 * sy), 1.1 * sx, Paint()..color = Colors.white.withOpacity(0.5));
    }

    // Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF1C3048)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 * sx
      ..strokeCap = StrokeCap.round;

    final mouthFill = Paint()..color = const Color(0xFF1C3048);

    Path mouth;
    switch (emo) {
      case NimbusEmo.happy:
      case NimbusEmo.idle:
      case NimbusEmo.curious:
        mouth = Path()..moveTo(50 * sx, 76 * sy)..quadraticBezierTo(60 * sx, 85 * sy, 70 * sx, 76 * sy);
        canvas.drawPath(mouth, mouthPaint);
        break;
      case NimbusEmo.excited:
        mouth = Path()..moveTo(46 * sx, 75 * sy)..quadraticBezierTo(60 * sx, 88 * sy, 74 * sx, 75 * sy);
        canvas.drawPath(mouth, mouthPaint..strokeWidth = 2.6 * sx);
        break;
      case NimbusEmo.surprised:
        canvas.drawOval(Rect.fromCenter(center: Offset(60 * sx, 79 * sy), width: 9 * sx, height: 10 * sy), mouthFill);
        break;
      case NimbusEmo.sad:
        mouth = Path()..moveTo(50 * sx, 83 * sy)..quadraticBezierTo(60 * sx, 74 * sy, 70 * sx, 83 * sy);
        canvas.drawPath(mouth, mouthPaint);
        // Tears
        canvas.drawOval(Rect.fromCenter(center: Offset(43 * sx, 73 * sy), width: 5.6 * sx, height: 7.6 * sy), Paint()..color = const Color(0xFF74B9FF).withOpacity(0.9));
        canvas.drawOval(Rect.fromCenter(center: Offset(77 * sx, 73 * sy), width: 5.6 * sx, height: 7.6 * sy), Paint()..color = const Color(0xFF74B9FF).withOpacity(0.9));
        break;
      case NimbusEmo.sleep:
        mouth = Path()..moveTo(52 * sx, 79 * sy)..quadraticBezierTo(60 * sx, 80 * sy, 68 * sx, 79 * sy);
        canvas.drawPath(mouth, mouthPaint);
        break;
    }

    // Stars for happy/excited
    if (emo == NimbusEmo.happy || emo == NimbusEmo.excited) {
      final starPainter = TextPainter(textDirection: TextDirection.ltr);
      starPainter.text = TextSpan(text: '★', style: TextStyle(color: const Color(0xFFFFE066), fontSize: 12 * sx, decoration: TextDecoration.none));
      starPainter.layout();
      starPainter.paint(canvas, Offset(8 * sx, 44 * sy));
      starPainter.paint(canvas, Offset(96 * sx, 42 * sy));
      
      starPainter.text = TextSpan(text: '✦', style: TextStyle(color: const Color(0xFFFFD32A), fontSize: 9 * sx, decoration: TextDecoration.none));
      starPainter.layout();
      starPainter.paint(canvas, Offset(52 * sx, 14 * sy));
    }

    // Question mark for curious
    if (emo == NimbusEmo.curious) {
      final qPainter = TextPainter(textDirection: TextDirection.ltr);
      qPainter.text = TextSpan(text: '?', style: TextStyle(color: const Color(0xFF1C3048), fontSize: 28 * sx, fontWeight: FontWeight.bold, decoration: TextDecoration.none));
      qPainter.layout();
      qPainter.paint(canvas, Offset(50 * sx, -15 * sy));
    }

    // Blush for sad
    if (emo == NimbusEmo.sad) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(43 * sx, 73 * sy), width: 5.6 * sx, height: 7.6 * sy),
        Paint()..color = const Color(0xFF74B9FF).withOpacity(0.9),
      );
    }
  }

  Path _buildCloudPath(double sx, double sy) {
    return Path()
      ..moveTo(12 * sx, 80 * sy)
      ..cubicTo(5 * sx, 80 * sy, 3 * sx, 70 * sy, 9 * sx, 64 * sy)
      ..cubicTo(3 * sx, 54 * sy, 9 * sx, 40 * sy, 24 * sx, 40 * sy)
      ..cubicTo(19 * sx, 28 * sy, 40 * sx, 22 * sy, 51 * sx, 35 * sy)
      ..cubicTo(53 * sx, 22 * sy, 67 * sx, 22 * sy, 69 * sx, 35 * sy)
      ..cubicTo(80 * sx, 22 * sy, 101 * sx, 28 * sy, 96 * sx, 40 * sy)
      ..cubicTo(111 * sx, 40 * sy, 117 * sx, 54 * sy, 111 * sx, 64 * sy)
      ..cubicTo(117 * sx, 70 * sy, 115 * sx, 80 * sy, 108 * sx, 80 * sy)
      ..cubicTo(106 * sx, 96 * sy, 14 * sx, 96 * sy, 12 * sx, 80 * sy)
      ..close();
  }

  @override
  bool shouldRepaint(_NimbusCloudPainter oldDelegate) => oldDelegate.emo != emo;
}
