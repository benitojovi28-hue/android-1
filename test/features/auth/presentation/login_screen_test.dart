import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/auth/data/auth_repository.dart';
import 'package:mywork/features/auth/presentation/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.signInError});

  final Object? signInError;
  int signInWithPasswordCalls = 0;

  @override
  Future<AuthResponse> signInWithPassword({required String email, required String password}) async {
    signInWithPasswordCalls++;
    if (signInError != null) throw signInError!;
    return AuthResponse();
  }

  @override
  User? get currentUser => throw UnimplementedError();

  @override
  Stream<AuthState> get authStateChanges => throw UnimplementedError();

  @override
  Future<void> signInWithPhoneOtp(String phone) => throw UnimplementedError();

  @override
  Future<AuthResponse> verifyPhoneOtp({required String phone, required String token}) =>
      throw UnimplementedError();

  @override
  Future<void> signInWithEmailOtp(String email) => throw UnimplementedError();

  @override
  Future<AuthResponse> verifyEmailOtp({required String email, required String token}) =>
      throw UnimplementedError();

  @override
  Future<AuthResponse> signUp({required String email, required String password, Map<String, dynamic>? data}) =>
      throw UnimplementedError();

  @override
  Future<void> resetPasswordForEmail(String email) => throw UnimplementedError();

  @override
  Future<void> updatePassword(String newPassword) => throw UnimplementedError();

  @override
  Future<AuthResponse> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<AuthResponse> signInWithApple() => throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();
}

void main() {
  Future<void> pumpLoginScreen(WidgetTester tester, AuthRepository authRepository) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
  }

  testWidgets('shows an error message when password sign-in fails', (tester) async {
    final fakeAuthRepository = _FakeAuthRepository(signInError: Exception('invalid credentials'));
    await pumpLoginScreen(tester, fakeAuthRepository);

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'alex@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Mot de passe'), 'secret123');

    expect(find.text('Connexion impossible. Vérifiez vos identifiants.'), findsNothing);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Connexion impossible. Vérifiez vos identifiants.'), findsOneWidget);
    expect(fakeAuthRepository.signInWithPasswordCalls, 1);
  });

  testWidgets('does not submit and shows no error when the form is invalid', (tester) async {
    final fakeAuthRepository = _FakeAuthRepository();
    await pumpLoginScreen(tester, fakeAuthRepository);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Se connecter'));
    await tester.pump();

    expect(fakeAuthRepository.signInWithPasswordCalls, 0);
    expect(find.text('Email invalide'), findsOneWidget);
    expect(find.text('Mot de passe requis'), findsOneWidget);
  });
}
