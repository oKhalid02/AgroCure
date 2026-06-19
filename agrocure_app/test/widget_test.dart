// Smoke test: the app boots to the splash, then routes onward.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agrocure_app/main.dart';

void main() {
  testWidgets('boots to splash and into onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AgroCureApp());
    expect(find.text('AgroCure'), findsOneWidget); // splash

    await tester.pump(const Duration(milliseconds: 1800)); // splash timer fires
    await tester.pump(const Duration(milliseconds: 600)); // fade transition

    expect(find.text('Snap a leaf'), findsOneWidget); // onboarding slide 1
  });
}
