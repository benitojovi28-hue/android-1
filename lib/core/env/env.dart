class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Web OAuth Client ID from Google Cloud Console. Required on Android so
  /// the ID token's audience matches what's registered as a trusted client
  /// in Supabase Auth's Google provider settings; also used on iOS.
  static const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  /// iOS OAuth Client ID from Google Cloud Console (the one whose bundle ID
  /// matches this app) — required for native Google Sign-In on iOS only.
  static const googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  static bool get isGoogleSignInConfigured => googleServerClientId.isNotEmpty;

  static void assertConfigured() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'Missing Supabase configuration. Run with '
        '--dart-define-from-file=env/dev.json (see env/dev.json.example).',
      );
    }
  }
}
