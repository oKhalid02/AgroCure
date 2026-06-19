import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'theme/botanica_theme.dart';
import 'services/settings_service.dart';
import 'screens/splash_screen.dart';

/// Drives the live light/dark/system switch.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void toggleTheme() {
  setThemeMode(
    themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
  );
}

void setThemeMode(ThemeMode mode) {
  themeNotifier.value = mode;
  SettingsService.setThemeMode(mode);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    // ignore: deprecated_member_use
    anonKey: SupabaseConfig.anonKey, // legacy anon JWT (intentional)
  );
  themeNotifier.value = await SettingsService.loadThemeMode();
  runApp(const AgroCureApp());
}

class AgroCureApp extends StatelessWidget {
  const AgroCureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) => MaterialApp(
        title: 'AgroCure',
        debugShowCheckedModeBanner: false,
        theme: BotanicaTheme.light,
        darkTheme: BotanicaTheme.dark,
        themeMode: mode,
        home: const SplashScreen(),
      ),
    );
  }
}
