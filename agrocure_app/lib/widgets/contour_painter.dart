import 'package:flutter/material.dart';

/// Topographic botanical contour lines — the signature texture inside the
/// hero card. Pure line art, so it stays crisp at any size.
class ContourPainter extends CustomPainter {
  final Color color;
  final int lines;
  final double amplitude;

  ContourPainter({
    required this.color,
    this.lines = 6,
    this.amplitude = 26,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final gap = size.height / (lines - 0.5);

    for (int i = 0; i < lines; i++) {
      final y = gap * (i + 0.2);
      final path = Path()..moveTo(-w * 0.05, y);
      path.cubicTo(
        w * 0.22, y - amplitude,
        w * 0.40, y + amplitude,
        w * 0.55, y,
      );
      path.cubicTo(
        w * 0.74, y - amplitude,
        w * 0.96, y + amplitude,
        w * 1.05, y,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ContourPainter old) =>
      old.color != color || old.lines != lines || old.amplitude != amplitude;
}
