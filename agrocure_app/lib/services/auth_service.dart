import 'package:shared_preferences/shared_preferences.dart';

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

/// Local authentication. Persists a session in SharedPreferences.
///
/// This is a self-contained implementation so the full flow works offline.
/// To move to real cloud auth, swap the bodies of these methods for Firebase
/// Auth calls — the rest of the app talks only to this interface.
class AuthService {
  static const _kLoggedIn = 'auth_logged_in';
  static const _kName = 'auth_name';
  static const _kEmail = 'auth_email';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kLoggedIn) ?? false;
  }

  static Future<AuthUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_kLoggedIn) ?? false)) return null;
    return AuthUser(
      name: prefs.getString(_kName) ?? 'Guest',
      email: prefs.getString(_kEmail) ?? '',
    );
  }

  static Future<AuthUser> signIn({
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, true);
    await prefs.setString(_kName, name);
    await prefs.setString(_kEmail, email);
    return AuthUser(name: name, email: email);
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLoggedIn, false);
  }
}
