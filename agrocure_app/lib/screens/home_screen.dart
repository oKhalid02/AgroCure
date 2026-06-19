import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../main.dart';
import '../theme/botanica_theme.dart';
import '../widgets/seedling_logo.dart';
import '../widgets/contour_painter.dart';
import '../widgets/ambient_background.dart';
import 'camera_screen.dart';
import 'history_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: c.bg,
      // The dock owns a real layout slot, so the body is always laid out
      // above it and can never overlap — on any screen size.
      bottomNavigationBar: _glassDock(context, c, isDark),
      body: AmbientBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(context, c, isDark),
                _greeting(c).animate().fadeIn(duration: 400.ms),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                  child: _heroCard(context, c, isDark),
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.06),
                _statsLine(c).animate().fadeIn(delay: 300.ms),
                _tiles(context, c, isDark).animate().fadeIn(delay: 380.ms),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
                  child: Text('HOW IT WORKS',
                      style: TextStyle(
                          fontSize: 10, color: c.ink3, letterSpacing: 1.8)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
                  child: _howItWorks(c, isDark),
                ).animate().fadeIn(delay: 450.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------- top bar
  Widget _topBar(BuildContext context, BotanicaColors c, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      child: Row(
        children: [
          SeedlingLogo(
            size: 32,
            leafColor: isDark ? c.accInk : c.acc,
            bgColor: isDark ? c.acc : c.ink,
          ),
          const SizedBox(width: 9),
          Text('AgroCure', style: Serif.style(17, c.ink, letterSpacing: -0.3)),
          const Spacer(),
          _circle(
            c,
            child: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 16,
              color: c.ink,
            ),
            onTap: toggleTheme,
          ),
          const SizedBox(width: 10),
          _circle(
            c,
            onTap: () => _open(context, const ProfileScreen()),
            child: Text('K',
                style: TextStyle(
                    color: c.ink, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- greeting
  Widget _greeting(BotanicaColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GOOD MORNING, KHALED',
              style: TextStyle(fontSize: 10, color: c.ink3, letterSpacing: 1.8)),
          const SizedBox(height: 7),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: "Let's check your\n",
                  style: Serif.style(28, c.ink, height: 1.05)),
              TextSpan(
                  text: 'garden.',
                  style: Serif.style(28, c.ink, italic: true, height: 1.05)),
            ]),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ hero
  Widget _heroCard(BuildContext context, BotanicaColors c, bool isDark) {
    return GestureDetector(
      onTap: () => _openCamera(context),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [c.hero, Color.lerp(c.hero, Colors.black, 0.22)!],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.14),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter:
                      ContourPainter(color: c.heroLeaf.withValues(alpha: 0.18)),
                ),
              ),
              Positioned(
                right: 20,
                top: 20,
                child: Opacity(
                  opacity: 0.9,
                  child: SeedlingLogo(
                      size: 58, leafColor: c.heroLeaf, strokeWidth: 1.6),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.acc,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('AI DIAGNOSIS',
                          style: TextStyle(
                              color: c.accInk,
                              fontSize: 9,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 11),
                    Text('Scan a leaf', style: Serif.style(26, c.heroInk)),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 190,
                      child: Text(
                        'Detect disease in seconds — one clear photo is all it takes.',
                        style: TextStyle(
                            color: c.heroInk2, fontSize: 11, height: 1.45),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 19, vertical: 11),
                      decoration: BoxDecoration(
                        color: c.heroCta,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: c.acc.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Open camera',
                              style: TextStyle(
                                  color: c.heroCtaInk,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward,
                              color: c.heroCtaInk, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------- stats
  Widget _statsLine(BotanicaColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          _stat(c, '93%', 'accuracy'),
          _dot(c),
          _stat(c, '16', 'plants'),
          _dot(c),
          _stat(c, '30', 'diseases'),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- tiles
  Widget _tiles(BuildContext context, BotanicaColors c, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Row(
        children: [
          Expanded(
            child: _actionTile(
              c,
              isDark,
              accent: c.sage,
              title: 'Talk to Sage',
              subtitle: 'Ask about any plant',
              seedling: true,
              onTap: () => _open(context, const ChatScreen()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _actionTile(
              c,
              isDark,
              accent: c.terra,
              title: 'History',
              subtitle: 'Your past scans',
              icon: Icons.history,
              onTap: () => _open(context, const HistoryScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
    BotanicaColors c,
    bool isDark, {
    required Color accent,
    required String title,
    required String subtitle,
    IconData? icon,
    bool seedling = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: c.surf,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: c.line),
          boxShadow: _softShadow(isDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: seedling
                      ? SeedlingLogo(
                          size: 22, leafColor: accent, strokeWidth: 1.8)
                      : Icon(icon, color: accent, size: 18),
                ),
                const Spacer(),
                Icon(Icons.north_east, color: c.ink3, size: 15),
              ],
            ),
            const SizedBox(height: 13),
            Text(title,
                style: TextStyle(
                    color: c.ink, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(subtitle, style: TextStyle(color: c.ink3, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------- how it works
  Widget _howItWorks(BotanicaColors c, bool isDark) {
    Widget step(IconData icon, String label, Color accent) => Column(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 19),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: c.ink2, fontSize: 11)),
          ],
        );

    Widget connector() => Container(
          margin: const EdgeInsets.only(top: 21),
          width: 20,
          height: 1.5,
          color: c.line,
        );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      decoration: BoxDecoration(
        color: c.surf,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.line),
        boxShadow: _softShadow(isDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          step(Icons.camera_alt_outlined, 'Snap', c.sage),
          connector(),
          step(Icons.eco_outlined, 'Diagnose', c.acc),
          connector(),
          step(Icons.chat_bubble_outline, 'Treat', c.terra),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ glass dock
  Widget _glassDock(BuildContext context, BotanicaColors c, bool isDark) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 6, 16, bottomInset > 0 ? bottomInset : 14),
      child: SizedBox(
        height: 66,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // frosted pill
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 66,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: BoxDecoration(
                    color: c.surf.withValues(alpha: isDark ? 0.72 : 0.82),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: c.line),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.home_rounded, color: c.ink, size: 23),
                      GestureDetector(
                        onTap: () => _open(context, const ChatScreen()),
                        child: Icon(Icons.chat_bubble_outline,
                            color: c.ink3, size: 21),
                      ),
                      const SizedBox(width: 54), // gap for the raised button
                      GestureDetector(
                        onTap: () => _open(context, const HistoryScreen()),
                        child: Icon(Icons.history_rounded,
                            color: c.ink3, size: 22),
                      ),
                      GestureDetector(
                        onTap: () => _open(context, const ProfileScreen()),
                        child:
                            Icon(Icons.person_outline, color: c.ink3, size: 21),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // raised scan button (overlaid, never clipped)
            Positioned(
              top: -16,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => _openCamera(context),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: c.acc,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: c.acc.withValues(alpha: 0.5),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child:
                        Icon(Icons.camera_alt_rounded, color: c.accInk, size: 25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- helpers
  List<BoxShadow> _softShadow(bool isDark) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  Widget _circle(BotanicaColors c,
      {required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 33,
        height: 33,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.surf,
          shape: BoxShape.circle,
          border: Border.all(color: c.line),
        ),
        child: child,
      ),
    );
  }

  Widget _stat(BotanicaColors c, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: Serif.style(13, c.ink)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: c.ink3)),
      ],
    );
  }

  Widget _dot(BotanicaColors c) =>
      Text('·', style: TextStyle(color: c.line, fontSize: 14));
}
