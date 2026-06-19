import 'package:flutter/material.dart';
import '../theme/botanica_theme.dart';
import '../services/settings_service.dart';
import '../widgets/ambient_background.dart';
import '../widgets/buttons.dart';
import 'login_screen.dart';

class _Slide {
  final IconData icon;
  final Color accent;
  final String title;
  final String body;
  const _Slide(this.icon, this.accent, this.title, this.body);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await SettingsService.setOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _next(int last) {
    if (_page >= last) {
      _finish();
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final slides = [
      _Slide(Icons.camera_alt_rounded, c.sage, 'Snap a leaf',
          'Point your camera at any crop leaf and capture a clear photo.'),
      _Slide(Icons.eco_rounded, c.acc, 'Instant diagnosis',
          'AgroCure identifies the plant and detects disease in seconds — 93% accurate across 30 conditions.'),
      _Slide(Icons.chat_bubble_rounded, c.terra, 'Meet Sage',
          'Chat with your AI companion for treatment plans and plant-care advice.'),
    ];
    final last = slides.length - 1;

    return Scaffold(
      backgroundColor: c.bg,
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 18, 0),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text('Skip',
                        style: TextStyle(color: c.ink3, fontSize: 13)),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => _slideView(c, slides[i]),
                ),
              ),
              // dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active ? c.acc : c.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                child: PrimaryButton(
                  label: _page >= last ? 'Get started' : 'Next',
                  icon: _page >= last ? Icons.arrow_forward : null,
                  onTap: () => _next(last),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slideView(BotanicaColors c, _Slide s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: s.accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: s.accent.withValues(alpha: 0.25),
                    blurRadius: 40,
                    spreadRadius: 4),
              ],
            ),
            child: Icon(s.icon, color: s.accent, size: 52),
          ),
          const SizedBox(height: 40),
          Text(s.title,
              textAlign: TextAlign.center, style: Serif.style(28, c.ink)),
          const SizedBox(height: 14),
          Text(s.body,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.ink2, fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }
}
