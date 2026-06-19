import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/botanica_theme.dart';
import '../services/auth_service.dart';
import '../widgets/ambient_background.dart';
import '../widgets/buttons.dart';
import '../widgets/app_text_field.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _snack('Fill in your name, email and password');
      return;
    }
    if (password.length < 6) {
      _snack('Password must be at least 6 characters');
      return;
    }
    setState(() => _busy = true);
    try {
      await AuthService.signUp(name: name, email: email, password: password);
      if (!mounted) return;
      if (AuthService.isLoggedIn) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      } else {
        setState(() => _busy = false);
        _snack('Account created — check your email to confirm, then sign in.');
        Navigator.pop(context);
      }
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
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CircleIconButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => Navigator.pop(context)),
                ),
                const SizedBox(height: 28),
                Text('Create account', style: Serif.style(30, c.ink)),
                const SizedBox(height: 8),
                Text('Start diagnosing your plants',
                    style: TextStyle(color: c.ink3, fontSize: 14)),
                const SizedBox(height: 34),
                AppTextField(
                    controller: _name,
                    hint: 'Full name',
                    icon: Icons.person_outline),
                const SizedBox(height: 14),
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
                const SizedBox(height: 24),
                PrimaryButton(
                  label: _busy ? 'Creating…' : 'Create account',
                  onTap: _busy ? null : _create,
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'By continuing you agree to our Terms & Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.ink3, fontSize: 11, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
