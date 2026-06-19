import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/botanica_theme.dart';

/// Radial confidence gauge — an organic arc with the percentage cradled in
/// its centre. Animates the sweep on first build.
class ConfidenceDial extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final String label;

  const ConfidenceDial({
    super.key,
    required this.value,
    this.size = 112,
    this.label = 'Confident',
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final pct = (value * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => CustomPaint(
              size: Size(size, size),
              painter: _DialPainter(
                value: v,
                track: c.track,
                arc: c.sage,
                stroke: size * 0.08,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$pct%', style: Serif.style(size * 0.23, c.ink)),
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: size * 0.082,
                  color: c.ink3,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final double value;
  final Color track;
  final Color arc;
  final double stroke;

  _DialPainter({
    required this.value,
    required this.track,
    required this.arc,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, trackPaint);

    final arcPaint = Paint()
      ..color = arc
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.value != value || old.track != track || old.arc != arc;
}
