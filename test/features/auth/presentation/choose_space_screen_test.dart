import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/auth/data/auth_repository.dart';
import 'package:mywork/features/auth/presentation/choose_space_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthRepository implements AuthRepository {
  int signOutCalls = 0;

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }

  @override
  User? get currentUser => throw UnimplementedError();

  @override
  Stream<AuthState> get authStateChanges => throw UnimplementedError();

  @override
  Future<AuthResponse> signInWithPassword({required String email, required String password}) =>
      throw UnimplementedError();

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
}

void main() {
  testWidgets('renders the explanation and lets the user sign out', (tester) async {
    final fakeAuthRepository = _FakeAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(fakeAuthRepository)],
        child: const MaterialApp(home: ChooseSpaceScreen()),
      ),
    );

    expect(find.text('Configurer un profil candidat'), findsOneWidget);
    expect(find.text('Configurer un profil entreprise'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);

    await tester.tap(find.text('Se déconnecter'));
    await tester.pump();

    expect(fakeAuthRepository.signOutCalls, 1);
  });
}
