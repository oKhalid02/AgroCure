import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/botanica_theme.dart';
import '../services/auth_service.dart';
import '../widgets/seedling_logo.dart';
import '../widgets/ambient_background.dart';
import '../widgets/buttons.dart';
import '../widgets/app_text_field.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _go(String name, String email) async {
    setState(() => _busy = true);
    await AuthService.signIn(name: name, email: email);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  void _emailSignIn() {
    final email = _email.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email to continue')),
      );
      return;
    }
    final name = email.split('@').first;
    _go(name[0].toUpperCase() + name.substring(1), email);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Scaffold(
      backgroundColor: c.bg,
      body: AmbientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                Center(
                  child: SeedlingLogo(size: 64, leafColor: c.acc, bgColor: c.ink),
                ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
                const SizedBox(height: 26),
                Text('Welcome back',
                    textAlign: TextAlign.center, style: Serif.style(30, c.ink)),
                const SizedBox(height: 8),
                Text('Sign in to your garden',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.ink3, fontSize: 14)),
                const SizedBox(height: 36),
                AppTextField(
                  controller: _email,
                  hint: 'Email',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _password,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  obscure: true,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('Forgot password?',
                      style: TextStyle(color: c.ink3, fontSize: 12)),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: _busy ? 'Signing in…' : 'Sign in',
                  onTap: _busy ? null : _emailSignIn,
                ),
                const SizedBox(height: 22),
                _divider(c),
                const SizedBox(height: 22),
                _socialButton(c, Icons.g_mobiledata, 'Continue with Google',
                    () => _go('Khaled', 'khaled.alamro2002@gmail.com')),
                const SizedBox(height: 12),
                _socialButton(c, Icons.apple, 'Continue with Apple',
                    () => _go('Khaled', 'khaled@icloud.com')),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New here? ",
                        style: TextStyle(color: c.ink3, fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SignupScreen()),
                      ),
                      child: Text('Create account',
                          style: TextStyle(
                              color: c.sage,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider(BotanicaColors c) {
    return Row(
      children: [
        Expanded(child: Divider(color: c.line)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(color: c.ink3, fontSize: 12)),
        ),
        Expanded(child: Divider(color: c.line)),
      ],
    );
  }

  Widget _socialButton(
      BotanicaColors c, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: c.surf,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: c.line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: c.ink, size: 22),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    color: c.ink, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
