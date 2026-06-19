/// App configuration.
///
/// The backend base URL is resolved at build/run time so the same codebase
/// can point at a local server during development or the live backend in
/// production — without editing source.
///
/// Local development (default):
///   flutter run
///
/// Against the live Hugging Face backend:
///   flutter run --dart-define=API_URL=https://YOUR-SPACE.hf.space
///
/// Production build:
///   flutter build apk  --dart-define=API_URL=https://YOUR-SPACE.hf.space
///   flutter build ipa  --dart-define=API_URL=https://YOUR-SPACE.hf.space
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}

/// Supabase project credentials. The anon key is a public client key — it is
/// safe to ship in the app; row-level security on the server enforces access.
class SupabaseConfig {
  static const String url = 'https://dbhajzlrherhmqlcguni.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRiaGFqemxyaGVyaG1xbGNndW5pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE4NjY1OTEsImV4cCI6MjA5NzQ0MjU5MX0.LwQegP_2CPG0QYk7Xm8qWpKOFmIzx6fGAlW3yYNGt5M';
}
