import 'package:flutter/material.dart';
import '../theme/botanica_theme.dart';
import '../services/auth_service.dart';
import '../services/history_service.dart';
import '../widgets/ambient_background.dart';
import '../widgets/buttons.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AuthUser? _user;
  int _scans = 0;
  int _plants = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService.currentUser();
    final history = await HistoryService.load();
    if (!mounted) return;
    setState(() {
      _user = user;
      _scans = history.length;
      _plants = history.map((p) => p.plant).toSet().length;
    });
  }

  Future<void> _signOut() async {
    await AuthService.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final user = _user;

    return Scaffold(
      backgroundColor: c.bg,
      body: AmbientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleIconButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 12),
                    Text('Profile', style: Serif.style(18, c.ink)),
                  ],
                ),
                const SizedBox(height: 28),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.acc.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                          border: Border.all(color: c.acc, width: 2),
                        ),
                        child: Text(user?.initials ?? '…',
                            style: Serif.style(30, c.ink)),
                      ),
                      const SizedBox(height: 16),
                      Text(user?.name ?? 'Guest',
                          style: Serif.style(24, c.ink)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '',
                          style: TextStyle(color: c.ink3, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    _statCard(c, '$_scans', 'Scans'),
                    const SizedBox(width: 12),
                    _statCard(c, '$_plants', 'Plants'),
                    const SizedBox(width: 12),
                    _statCard(c, '93%', 'Accuracy'),
                  ],
                ),
                const SizedBox(height: 24),
                _row(c, Icons.settings_outlined, 'Settings', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()));
                }),
                _row(c, Icons.info_outline, 'About AgroCure',
                    () => _about(context, c)),
                _row(c, Icons.logout, 'Sign out', _signOut, danger: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(BotanicaColors c, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: c.surf,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.line),
        ),
        child: Column(
          children: [
            Text(value, style: Serif.style(22, c.ink)),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: c.ink3, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _row(BotanicaColors c, IconData icon, String label, VoidCallback onTap,
      {bool danger = false}) {
    final color = danger ? c.terra : c.ink;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: c.surf,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.line),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            if (!danger)
              Icon(Icons.chevron_right, color: c.ink3, size: 20),
          ],
        ),
      ),
    );
  }

  void _about(BuildContext context, BotanicaColors c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.surf,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('AgroCure', style: Serif.style(20, c.ink)),
        content: Text(
          'AI-powered plant disease diagnosis.\n\n'
          'A two-stage hierarchical model (EfficientNetV2-S) covering 16 plants '
          'and 30 diseases at 93% accuracy, with Sage — an AI plant-care companion.\n\n'
          'Version 4.0.0',
          style: TextStyle(color: c.ink2, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: c.sage)),
          ),
        ],
      ),
    );
  }
}
