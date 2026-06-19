import 'package:flutter/material.dart';
import '../theme/botanica_theme.dart';

/// Filled primary action — forest in light, chartreuse in dark.
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const PrimaryButton({super.key, required this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: onTap == null ? c.btn.withValues(alpha: 0.5) : c.btn,
          borderRadius: BorderRadius.circular(30),
          boxShadow: onTap == null
              ? null
              : [
                  BoxShadow(
                    color: c.btn.withValues(alpha: 0.32),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: c.btnInk, size: 18),
              const SizedBox(width: 9),
            ],
            Text(
              label,
              style: TextStyle(
                color: c.btnInk,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Outlined secondary action.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const SecondaryButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: c.line),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(label, style: TextStyle(color: c.ink2, fontSize: 13)),
      ),
    );
  }
}

/// Small circular back / icon button used in app bars.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const CircleIconButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: c.surf,
          shape: BoxShape.circle,
          border: Border.all(color: c.line),
        ),
        child: Icon(icon, color: c.ink, size: 16),
      ),
    );
  }
}
