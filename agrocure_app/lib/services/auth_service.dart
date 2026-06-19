import 'package:supabase_flutter/supabase_flutter.dart';

class AuthUser {
  final String name;
  final String email;
  const AuthUser({required this.name, required this.email});

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

/// Authentication backed by Supabase Auth.
///
/// Sessions persist automatically across launches. The app talks only to this
/// interface, so the backend can be swapped without touching the screens.
class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  static bool get isLoggedIn => _client.auth.currentSession != null;

  static AuthUser? get currentUser {
    final u = _client.auth.currentUser;
    if (u == null) return null;
    final meta = u.userMetadata;
    final name = (meta?['name'] as String?)?.trim();
    return AuthUser(
      name: (name != null && name.isNotEmpty)
          ? name
          : (u.email?.split('@').first ?? 'User'),
      email: u.email ?? '',
    );
  }

  /// Creates an account. With email-confirmation disabled (recommended for the
  /// prototype) the user is signed in immediately and [isLoggedIn] becomes true.
  static Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
