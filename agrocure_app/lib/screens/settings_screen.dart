import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/botanica_theme.dart';
import '../services/settings_service.dart';
import '../widgets/ambient_background.dart';
import '../widgets/buttons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _lang = 'en';
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    SettingsService.language().then((v) => setState(() => _lang = v));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Scaffold(
      backgroundColor: c.bg,
      body: AmbientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
            children: [
              Row(
                children: [
                  CircleIconButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  Text('Settings', style: Serif.style(18, c.ink)),
                ],
              ),
              const SizedBox(height: 24),

              _label(c, 'APPEARANCE'),
              _card(c, child: _themeSelector(c)),

              const SizedBox(height: 22),
              _label(c, 'GENERAL'),
              _card(
                c,
                child: Column(
                  children: [
                    _langRow(c),
                    Divider(color: c.line, height: 1),
                    _switchRow(c, Icons.notifications_outlined, 'Notifications',
                        _notifications, (v) => setState(() => _notifications = v)),
                  ],
                ),
              ),

              const SizedBox(height: 22),
              _label(c, 'ABOUT'),
              _card(
                c,
                child: Column(
                  children: [
                    _infoRow(c, 'Version', '4.0.0'),
                    Divider(color: c.line, height: 1),
                    _infoRow(c, 'Model', 'EfficientNetV2-S · v4'),
                    Divider(color: c.line, height: 1),
                    _infoRow(c, 'Coverage', '16 plants · 30 diseases'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(BotanicaColors c, String t) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(t,
            style: TextStyle(fontSize: 10, color: c.ink3, letterSpacing: 1.8)),
      );

  Widget _card(BotanicaColors c, {required Widget child}) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: c.surf,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.line),
        ),
        child: child,
      );

  Widget _themeSelector(BotanicaColors c) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        Widget seg(ThemeMode m, IconData icon, String label) {
          final active = mode == m;
          return Expanded(
            child: GestureDetector(
              onTap: () => setThemeMode(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: active ? c.acc : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(
                  children: [
                    Icon(icon,
                        size: 19, color: active ? c.accInk : c.ink2),
                    const SizedBox(height: 5),
                    Text(label,
                        style: TextStyle(
                            fontSize: 11,
                            color: active ? c.accInk : c.ink2,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          );
        }

        return Row(
          children: [
            seg(ThemeMode.light, Icons.light_mode_outlined, 'Light'),
            seg(ThemeMode.dark, Icons.dark_mode_outlined, 'Dark'),
            seg(ThemeMode.system, Icons.brightness_auto_outlined, 'System'),
          ],
        );
      },
    );
  }

  Widget _langRow(BotanicaColors c) {
    final label = _lang == 'ar' ? 'العربية' : 'English';
    return GestureDetector(
      onTap: () => _pickLanguage(c),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.translate, color: c.ink2, size: 20),
            const SizedBox(width: 14),
            Text('Language',
                style: TextStyle(color: c.ink, fontSize: 14)),
            const Spacer(),
            Text(label, style: TextStyle(color: c.ink3, fontSize: 13)),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: c.ink3, size: 20),
          ],
        ),
      ),
    );
  }

  void _pickLanguage(BotanicaColors c) {
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surf,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text('Language', style: Serif.style(18, c.ink)),
            const SizedBox(height: 12),
            _langOption(c, 'en', 'English'),
            _langOption(c, 'ar', 'العربية'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _langOption(BotanicaColors c, String code, String label) {
    final selected = _lang == code;
    return ListTile(
      title: Text(label, style: TextStyle(color: c.ink, fontSize: 15)),
      trailing: selected ? Icon(Icons.check, color: c.sage) : null,
      onTap: () {
        SettingsService.setLanguage(code);
        setState(() => _lang = code);
        Navigator.pop(context);
        if (code == 'ar') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Arabic UI is on the way — preference saved.')),
          );
        }
      },
    );
  }

  Widget _switchRow(BotanicaColors c, IconData icon, String label, bool value,
      ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: c.ink2, size: 20),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(color: c.ink, fontSize: 14)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: c.accInk,
            activeTrackColor: c.acc,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BotanicaColors c, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: c.ink2, fontSize: 14)),
          const Spacer(),
          Text(value, style: TextStyle(color: c.ink3, fontSize: 13)),
        ],
      ),
    );
  }
}
