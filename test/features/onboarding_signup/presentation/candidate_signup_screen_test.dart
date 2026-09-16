import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/auth/data/auth_repository.dart';
import 'package:mywork/features/auth/data/role_repository.dart';
import 'package:mywork/features/auth/domain/role.dart';
import 'package:mywork/features/onboarding_signup/presentation/candidate_signup_screen.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';
import 'package:mywork/features/profile_candidate/data/candidate_profile_repository.dart';
import 'package:mywork/models/candidat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.session});

  final Session? session;
  int signUpCalls = 0;
  Map<String, dynamic>? lastSignUpData;

  @override
  Future<AuthResponse> signUp({required String email, required String password, Map<String, dynamic>? data}) async {
    signUpCalls++;
    lastSignUpData = data;
    return AuthResponse(session: session);
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

class _FakeRoleRepository implements RoleRepository {
  _FakeRoleRepository({this.candidatId = 'candidat-1'});

  final String? candidatId;
  int ensureCandidatProfileCalls = 0;

  @override
  Future<String?> ensureCandidatProfile() async {
    ensureCandidatProfileCalls++;
    return candidatId;
  }

  @override
  Future<Role> fetchAccountRole(String userId) => throw UnimplementedError();

  @override
  Future<String?> ensureEntrepriseProfile() => throw UnimplementedError();
}

class _FakeCandidateProfileRepository implements CandidateProfileRepository {
  int updateProfileCalls = 0;
  String? lastCandidatId;
  Map<String, dynamic>? lastChanges;

  @override
  Future<void> updateProfile(String candidatId, Map<String, dynamic> changes) async {
    updateProfileCalls++;
    lastCandidatId = candidatId;
    lastChanges = changes;
  }

  @override
  Future<String> uploadDocument({
    required String folderId,
    required String filename,
    required Uint8List bytes,
    required String contentType,
  }) =>
      throw UnimplementedError();

  @override
  Future<Candidat?> myProfile() => throw UnimplementedError();

  @override
  Future<String?> signedPhotoUrl(String path) => throw UnimplementedError();

  @override
  Future<Map<String, dynamic>?> myCvNumerique(String candidatId) => throw UnimplementedError();

  @override
  Future<void> saveCvNumerique(String candidatId, Map<String, dynamic> data) => throw UnimplementedError();
}

void main() {
  Future<void> fillForm(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextFormField, 'Prénom'), 'Alex');
    await tester.enterText(find.widgetWithText(TextFormField, 'Nom'), 'Nguema');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'alex@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Téléphone'), '+237600000000');
    await tester.enterText(find.widgetWithText(TextFormField, 'Mot de passe'), 'secret123');
  }

  testWidgets('stops after signUp and never provisions a profile when email confirmation is required', (
    tester,
  ) async {
    final fakeAuthRepository = _FakeAuthRepository(session: null);
    final fakeRoleRepository = _FakeRoleRepository();
    final fakeCandidateProfileRepository = _FakeCandidateProfileRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          roleRepositoryProvider.overrideWithValue(fakeRoleRepository),
          candidateProfileRepositoryProvider.overrideWithValue(fakeCandidateProfileRepository),
        ],
        child: const MaterialApp(home: CandidateSignupScreen()),
      ),
    );

    await fillForm(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Créer mon compte'));
    await tester.pump();
    await tester.pump();

    expect(fakeAuthRepository.signUpCalls, 1);
    expect(fakeRoleRepository.ensureCandidatProfileCalls, 0);
    expect(fakeCandidateProfileRepository.updateProfileCalls, 0);
    expect(find.textContaining('Compte créé'), findsOneWidget);
  });

  testWidgets('provisions the candidat profile and updates it when a session is returned', (tester) async {
    final user = User(
      id: 'u1',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: DateTime(2024).toIso8601String(),
    );
    final session = Session(accessToken: 'token', tokenType: 'bearer', user: user);
    final fakeAuthRepository = _FakeAuthRepository(session: session);
    final fakeRoleRepository = _FakeRoleRepository(candidatId: 'candidat-1');
    final fakeCandidateProfileRepository = _FakeCandidateProfileRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          roleRepositoryProvider.overrideWithValue(fakeRoleRepository),
          candidateProfileRepositoryProvider.overrideWithValue(fakeCandidateProfileRepository),
        ],
        child: const MaterialApp(home: CandidateSignupScreen()),
      ),
    );

    await fillForm(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Créer mon compte'));
    await tester.pump();
    await tester.pump();

    expect(fakeAuthRepository.signUpCalls, 1);
    expect(fakeRoleRepository.ensureCandidatProfileCalls, 1);
    expect(fakeCandidateProfileRepository.updateProfileCalls, 1);
    expect(fakeCandidateProfileRepository.lastCandidatId, 'candidat-1');
    expect(fakeCandidateProfileRepository.lastChanges?['prenom'], 'Alex');
    expect(find.textContaining('Compte créé'), findsOneWidget);
  });

  testWidgets('shows an error and stops when profile provisioning fails', (tester) async {
    final user = User(
      id: 'u1',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: DateTime(2024).toIso8601String(),
    );
    final session = Session(accessToken: 'token', tokenType: 'bearer', user: user);
    final fakeAuthRepository = _FakeAuthRepository(session: session);
    final fakeRoleRepository = _FakeRoleRepository(candidatId: null);
    final fakeCandidateProfileRepository = _FakeCandidateProfileRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          roleRepositoryProvider.overrideWithValue(fakeRoleRepository),
          candidateProfileRepositoryProvider.overrideWithValue(fakeCandidateProfileRepository),
        ],
        child: const MaterialApp(home: CandidateSignupScreen()),
      ),
    );

    await fillForm(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Créer mon compte'));
    await tester.pump();
    await tester.pump();

    expect(fakeCandidateProfileRepository.updateProfileCalls, 0);
    expect(find.text("L'inscription a échoué. Réessayez."), findsOneWidget);
  });
}
