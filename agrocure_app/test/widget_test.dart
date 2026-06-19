// Smoke test: the login screen renders its core UI.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:agrocure_app/theme/botanica_theme.dart';
import 'package:agrocure_app/screens/login_screen.dart';

void main() {
  setUp(() {
    // Avoid network font fetches (and their timers) during the test.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('login screen renders', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: BotanicaTheme.light, home: const LoginScreen()),
    );
    // Let entry animations finish so no timers stay pending.
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
