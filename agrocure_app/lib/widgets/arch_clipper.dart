import 'package:flutter/material.dart';

/// The botanical "arch" / cathedral-window shape — rounded across the top,
/// squared at the bottom. Used to frame imagery and the camera viewfinder.
class ArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.62)
      ..cubicTo(0, h * 0.16, w * 0.22, 0, w * 0.5, 0)
      ..cubicTo(w * 0.78, 0, w, h * 0.16, w, h * 0.62)
      ..lineTo(w, h)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
