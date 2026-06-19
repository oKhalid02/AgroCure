import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide preferences: onboarding state, theme mode, language.
/// Persisted in SharedPreferences.
class SettingsService {
  static const _kOnboarding = 'onboarding_seen';
  static const _kTheme = 'theme_mode';
  static const _kLang = 'language';

  static Future<bool> onboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboarding) ?? false;
  }

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarding, true);
  }

  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final i = prefs.getInt(_kTheme) ?? 0; // 0 light, 1 dark, 2 system
    return ThemeMode.values[i.clamp(0, ThemeMode.values.length - 1)];
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTheme, mode.index);
  }

  static Future<String> language() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLang) ?? 'en';
  }

  static Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLang, code);
  }
}
