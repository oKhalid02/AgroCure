import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signIn() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      _snack('Enter your email and password');
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthService.signIn(email: email, password: password);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack('Something went wrong. Please try again.');
    }
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
                  onTap: _busy ? null : _signIn,
                ),
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

}
