import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LiquidPhysicsButton extends StatefulWidget {
  final Widget? child;
  final Widget Function(BuildContext context, bool isPressed)? builder;
  final VoidCallback onTap;
  final bool isWaterTheme;

  const LiquidPhysicsButton({
    super.key,
    this.child,
    this.builder,
    required this.onTap,
    this.isWaterTheme = false,
  }) : assert(child != null || builder != null);

  @override
  State<LiquidPhysicsButton> createState() => _LiquidPhysicsButtonState();
}

class _LiquidPhysicsButtonState extends State<LiquidPhysicsButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _dragOffset = Offset.zero;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanDown(_) {
    if (!widget.isWaterTheme) return;
    _controller.stop();
    setState(() { 
      _dragOffset = Offset.zero; 
      _isPressed = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isWaterTheme) return;
    setState(() {
      _dragOffset += details.delta * 0.4;
      if (_dragOffset.distance > 25) {
        _dragOffset = Offset.fromDirection(_dragOffset.direction, 25);
      }
    });
  }

  void _release() {
    if (!widget.isWaterTheme) return;
    _isPressed = false;
    _controller.forward(from: 0).then((_) {
      if (mounted) {
        setState(() { _dragOffset = Offset.zero; });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeChild = widget.builder != null ? widget.builder!(context, _isPressed) : widget.child!;

    if (!widget.isWaterTheme) {
      return GestureDetector(
        onTap: widget.onTap,
        child: activeChild,
      );
    }

    double bounce = _isPressed ? 1.0 : 0.0;
    if (_controller.isAnimating) {
      bounce = (1.0 - Curves.elasticOut.transform(_controller.value));
    }

    final currentOffset = _dragOffset * bounce;
    
    // Stretch based on drag direction, and slight shrink scale down on press
    final pressScale = _isPressed && currentOffset.distance == 0.0 ? 0.95 : 1.0;
    
    // In liquid, volume is preserved. Squish the perpendicular axis.
    final dxSquish = (currentOffset.dy.abs() / 150) * bounce;
    final dySquish = (currentOffset.dx.abs() / 150) * bounce;

    final stretchX = 1.0 + (currentOffset.dx.abs() / 60) * bounce - dxSquish;
    final stretchY = 1.0 + (currentOffset.dy.abs() / 60) * bounce - dySquish;

    return GestureDetector(
      onTap: () {
        if (widget.isWaterTheme) {
          HapticFeedback.lightImpact();
        }
        widget.onTap();
      },
      onPanDown: _onPanDown,
      onPanUpdate: _onPanUpdate,
      onPanEnd: (_) => _release(),
      onPanCancel: _release,
      child: Transform(
        transform: Matrix4.identity()
          ..translate(currentOffset.dx * 1.5, currentOffset.dy * 1.5)
          ..scale(pressScale * stretchX, pressScale * stretchY),
        alignment: Alignment.center,
        child: activeChild,
      ),
    );
  }
}
