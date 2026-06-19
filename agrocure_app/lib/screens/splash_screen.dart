import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/botanica_theme.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../widgets/seedling_logo.dart';
import '../widgets/ambient_background.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await Future.delayed(const Duration(milliseconds: 1700));
    if (!mounted) return;

    final seenOnboarding = await SettingsService.onboardingSeen();
    final loggedIn = AuthService.isLoggedIn;
    if (!mounted) return;

    final Widget next;
    if (!seenOnboarding) {
      next = const OnboardingScreen();
    } else if (!loggedIn) {
      next = const LoginScreen();
    } else {
      next = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      body: AmbientBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SeedlingLogo(
                size: 92,
                leafColor: c.acc,
                bgColor: c.ink,
              )
                  .animate()
                  .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      duration: 700.ms,
                      curve: Curves.easeOutBack)
                  .fadeIn(duration: 500.ms),
              const SizedBox(height: 22),
              Text('AgroCure', style: Serif.style(30, c.ink))
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 500.ms),
              const SizedBox(height: 8),
              Text('AI plant-disease diagnosis',
                      style: TextStyle(color: c.ink3, fontSize: 13))
                  .animate()
                  .fadeIn(delay: 550.ms),
            ],
          ),
        ),
      ),
    );
  }
}
