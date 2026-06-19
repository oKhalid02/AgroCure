import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/botanica_theme.dart';

/// A living botanical backdrop: a soft vertical gradient with two radial
/// "aurora" glows that slowly drift and breathe. Drop it at the bottom of a
/// Stack and layer content on top.
class AmbientBackground extends StatefulWidget {
  final Widget child;
  const AmbientBackground({super.key, required this.child});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(c.bg, c.acc, isDark ? 0.05 : 0.08)!,
                c.bg,
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final t = _ctrl.value * 2 * math.pi;
            return Stack(
              children: [
                Positioned(
                  top: 90 + 26 * math.sin(t),
                  right: -60 + 24 * math.cos(t),
                  child: _glow(
                      c.acc, (isDark ? 0.20 : 0.30) + 0.05 * math.sin(t), 290),
                ),
                Positioned(
                  top: 380 + 30 * math.cos(t * 0.8),
                  left: -80 + 22 * math.sin(t * 0.8),
                  child: _glow(
                      c.sage, (isDark ? 0.14 : 0.16) + 0.04 * math.cos(t), 250),
                ),
              ],
            );
          },
        ),
        widget.child,
      ],
    );
  }

  Widget _glow(Color color, double opacity, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity.clamp(0.0, 1.0)),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
