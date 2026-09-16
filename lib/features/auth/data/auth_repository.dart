import 'dart:io' show Platform;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mywork/core/utils/nonce.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signInWithPassword({required String email, required String password}) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signInWithPhoneOtp(String phone) {
    return _client.auth.signInWithOtp(phone: phone);
  }

  Future<AuthResponse> verifyPhoneOtp({required String phone, required String token}) {
    return _client.auth.verifyOTP(phone: phone, token: token, type: OtpType.sms);
  }

  Future<void> signInWithEmailOtp(String email) {
    return _client.auth.signInWithOtp(email: email);
  }

  Future<AuthResponse> verifyEmailOtp({required String email, required String token}) {
    return _client.auth.verifyOTP(email: email, token: token, type: OtpType.email);
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) {
    return _client.auth.signUp(email: email, password: password, data: data);
  }

  Future<void> resetPasswordForEmail(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String newPassword) {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Native Google Sign-In → Supabase session, via GoogleSignIn.instance
  /// (initialized once in main()) and Supabase's signInWithIdToken.
  Future<AuthResponse> signInWithGoogle() async {
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw Exception("Impossible de récupérer le jeton d'identité Google.");
    }
    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  /// Native "Sign in with Apple" → Supabase session. iOS/macOS only — Android
  /// support would require hosting a web OAuth redirect bridge for Apple's
  /// Service ID flow, which this app does not set up.
  Future<AuthResponse> signInWithApple() async {
    final rawNonce = generateRawNonce();
    final hashedNonce = sha256OfString(rawNonce);

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw Exception("Impossible de récupérer le jeton d'identité Apple.");
    }

    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  static bool get isAppleSignInAvailable => Platform.isIOS || Platform.isMacOS;

  Future<void> signOut() {
    return _client.auth.signOut();
  }
}
