import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/auth/data/auth_repository.dart';
import 'package:mywork/features/auth/data/role_repository.dart';
import 'package:mywork/features/auth/domain/role.dart';
import 'package:mywork/features/company/application/company_providers.dart';
import 'package:mywork/features/company/data/company_repository.dart';
import 'package:mywork/features/onboarding_signup/presentation/company_signup_screen.dart';
import 'package:mywork/models/candidature.dart';
import 'package:mywork/models/entreprise.dart';
import 'package:mywork/models/offre.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.session});

  final Session? session;
  int signUpCalls = 0;

  @override
  Future<AuthResponse> signUp({required String email, required String password, Map<String, dynamic>? data}) async {
    signUpCalls++;
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
  _FakeRoleRepository({this.entrepriseId = 'entreprise-1'});

  final String? entrepriseId;
  int ensureEntrepriseProfileCalls = 0;

  @override
  Future<String?> ensureEntrepriseProfile() async {
    ensureEntrepriseProfileCalls++;
    return entrepriseId;
  }

  @override
  Future<Role> fetchAccountRole(String userId) => throw UnimplementedError();

  @override
  Future<String?> ensureCandidatProfile() => throw UnimplementedError();
}

class _FakeCompanyRepository implements CompanyRepository {
  int updateCompanyCalls = 0;
  int uploadDocumentCalls = 0;

  @override
  Future<void> updateCompany(String entrepriseId, Map<String, dynamic> changes) async {
    updateCompanyCalls++;
  }

  @override
  Future<String> uploadDocument({
    required String folderId,
    required String filename,
    required Uint8List bytes,
    required String contentType,
  }) async {
    uploadDocumentCalls++;
    return 'documents/rccm.pdf';
  }

  @override
  Future<Entreprise?> myCompany() => throw UnimplementedError();

  @override
  Future<List<Offre>> myOffers(String entrepriseId) => throw UnimplementedError();

  @override
  Future<Offre> createOffer(Map<String, dynamic> data) => throw UnimplementedError();

  @override
  Future<void> updateOffer(String id, Map<String, dynamic> changes) => throw UnimplementedError();

  @override
  Future<void> archiveOffer(String id) => throw UnimplementedError();

  @override
  Future<List<Candidature>> applicationsForOffer(String offreId) => throw UnimplementedError();

  @override
  Future<List<Candidature>> allApplications(String entrepriseId) => throw UnimplementedError();
}

void main() {
  Future<void> fillForm(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextFormField, "Nom de l'entreprise"), 'Acme SARL');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'contact@acme.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Téléphone'), '+237600000000');
    await tester.enterText(find.widgetWithText(TextFormField, 'Mot de passe'), 'secret123');
  }

  testWidgets('stops after signUp and never provisions a profile when email confirmation is required', (
    tester,
  ) async {
    final fakeAuthRepository = _FakeAuthRepository(session: null);
    final fakeRoleRepository = _FakeRoleRepository();
    final fakeCompanyRepository = _FakeCompanyRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          roleRepositoryProvider.overrideWithValue(fakeRoleRepository),
          companyRepositoryProvider.overrideWithValue(fakeCompanyRepository),
        ],
        child: const MaterialApp(home: CompanySignupScreen()),
      ),
    );

    await fillForm(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Créer mon compte'));
    await tester.pump();
    await tester.pump();

    expect(fakeAuthRepository.signUpCalls, 1);
    expect(fakeRoleRepository.ensureEntrepriseProfileCalls, 0);
    expect(fakeCompanyRepository.updateCompanyCalls, 0);
    expect(find.textContaining('Compte créé'), findsOneWidget);
  });

  testWidgets('provisions the entreprise profile when a session is returned', (tester) async {
    final user = User(
      id: 'u1',
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: DateTime(2024).toIso8601String(),
    );
    final session = Session(accessToken: 'token', tokenType: 'bearer', user: user);
    final fakeAuthRepository = _FakeAuthRepository(session: session);
    final fakeRoleRepository = _FakeRoleRepository(entrepriseId: 'entreprise-1');
    final fakeCompanyRepository = _FakeCompanyRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          roleRepositoryProvider.overrideWithValue(fakeRoleRepository),
          companyRepositoryProvider.overrideWithValue(fakeCompanyRepository),
        ],
        child: const MaterialApp(home: CompanySignupScreen()),
      ),
    );

    await fillForm(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Créer mon compte'));
    await tester.pump();
    await tester.pump();

    expect(fakeAuthRepository.signUpCalls, 1);
    expect(fakeRoleRepository.ensureEntrepriseProfileCalls, 1);
    // No document was picked, so upload/update-with-rccm-url is skipped.
    expect(fakeCompanyRepository.uploadDocumentCalls, 0);
    expect(fakeCompanyRepository.updateCompanyCalls, 0);
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
    final fakeRoleRepository = _FakeRoleRepository(entrepriseId: null);
    final fakeCompanyRepository = _FakeCompanyRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          roleRepositoryProvider.overrideWithValue(fakeRoleRepository),
          companyRepositoryProvider.overrideWithValue(fakeCompanyRepository),
        ],
        child: const MaterialApp(home: CompanySignupScreen()),
      ),
    );

    await fillForm(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Créer mon compte'));
    await tester.pump();
    await tester.pump();

    expect(fakeCompanyRepository.updateCompanyCalls, 0);
    expect(find.text("L'inscription a échoué. Réessayez."), findsOneWidget);
  });
}
