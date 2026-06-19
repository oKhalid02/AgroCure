import 'package:flutter/material.dart';

/// The AgroCure seedling monogram — a two-leaf sprout, hand-drawn as line art.
/// Optionally sits inside a rounded-square badge ([bgColor]).
class SeedlingLogo extends StatelessWidget {
  final double size;
  final Color leafColor;
  final Color? bgColor;
  final double? strokeWidth;

  const SeedlingLogo({
    super.key,
    required this.size,
    required this.leafColor,
    this.bgColor,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SeedlingPainter(
          leafColor: leafColor,
          bgColor: bgColor,
          strokeWidth: strokeWidth ?? size * 0.05,
        ),
      ),
    );
  }
}

class _SeedlingPainter extends CustomPainter {
  final Color leafColor;
  final Color? bgColor;
  final double strokeWidth;

  _SeedlingPainter({
    required this.leafColor,
    required this.bgColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;

    if (bgColor != null) {
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s, s),
        Radius.circular(s * 0.3),
      );
      canvas.drawRRect(rrect, Paint()..color = bgColor!);
    }

    // Sprout drawn in a 48x48 space, then scaled to fit (with padding when badged).
    final pad = bgColor != null ? s * 0.22 : 0.0;
    final inner = s - pad * 2;
    final k = inner / 48.0;
    canvas.save();
    canvas.translate(pad, pad);

    final paint = Paint()
      ..color = leafColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth / k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.scale(k);

    // Stem
    final stem = Path()
      ..moveTo(24, 45)
      ..lineTo(24, 17);

    // Left leaf
    final left = Path()
      ..moveTo(24, 28)
      ..cubicTo(15, 30, 8, 24, 7, 15)
      ..cubicTo(15, 17, 22, 22, 24, 28)
      ..close();

    // Right leaf
    final right = Path()
      ..moveTo(24, 23)
      ..cubicTo(33, 25, 40, 19, 41, 10)
      ..cubicTo(33, 12, 26, 16, 24, 23)
      ..close();

    canvas.drawPath(stem, paint);
    canvas.drawPath(left, paint);
    canvas.drawPath(right, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SeedlingPainter old) =>
      old.leafColor != leafColor ||
      old.bgColor != bgColor ||
      old.strokeWidth != strokeWidth;
}
