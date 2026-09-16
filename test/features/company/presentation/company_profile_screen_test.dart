import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/company/application/company_providers.dart';
import 'package:mywork/features/company/data/company_repository.dart';
import 'package:mywork/features/company/presentation/company_profile_screen.dart';
import 'package:mywork/models/candidature.dart';
import 'package:mywork/models/entreprise.dart';
import 'package:mywork/models/offre.dart';

class FakeCompanyRepository implements CompanyRepository {
  String? lastUpdateId;
  Map<String, dynamic>? lastUpdateData;

  @override
  Future<void> updateCompany(String entrepriseId, Map<String, dynamic> changes) async {
    lastUpdateId = entrepriseId;
    lastUpdateData = changes;
  }

  @override
  Future<Entreprise?> myCompany() {
    throw UnimplementedError();
  }

  @override
  Future<String> uploadDocument({
    required String folderId,
    required String filename,
    required Uint8List bytes,
    required String contentType,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Offre>> myOffers(String entrepriseId) {
    throw UnimplementedError();
  }

  @override
  Future<Offre> createOffer(Map<String, dynamic> data) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateOffer(String id, Map<String, dynamic> changes) {
    throw UnimplementedError();
  }

  @override
  Future<void> archiveOffer(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Candidature>> applicationsForOffer(String offreId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Candidature>> allApplications(String entrepriseId) {
    throw UnimplementedError();
  }
}

const _entreprise = Entreprise(
  id: 'ent1',
  userId: 'user1',
  nom: 'Acme Corp',
  secteur: 'Informatique',
  ville: 'Douala',
  description: 'Une entreprise',
  verificationStatut: 'en_attente',
);

void main() {
  group('CompanyProfileScreen', () {
    testWidgets('shows a message when the company profile could not be found', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [myCompanyProvider.overrideWith((ref) async => null)],
          child: const MaterialApp(home: CompanyProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profil entreprise introuvable'), findsOneWidget);
    });

    testWidgets('pre-fills the form from the loaded company and shows its verification status', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myCompanyProvider.overrideWith((ref) async => _entreprise),
            companyRepositoryProvider.overrideWithValue(FakeCompanyRepository()),
          ],
          child: const MaterialApp(home: CompanyProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Acme Corp'), findsOneWidget);
      expect(find.text('Informatique'), findsOneWidget);
      expect(find.text('Douala'), findsOneWidget);
      expect(find.text('Une entreprise'), findsOneWidget);
      expect(find.text('Vérification : en_attente'), findsOneWidget);
    });

    testWidgets('saving submits the edited fields and shows a confirmation snackbar', (tester) async {
      final repo = FakeCompanyRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myCompanyProvider.overrideWith((ref) async => _entreprise),
            companyRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(home: CompanyProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Nom'), 'Nouveau Nom');
      await tester.tap(find.text('Enregistrer'));
      await tester.pump();
      await tester.pump();

      expect(repo.lastUpdateId, 'ent1');
      expect(repo.lastUpdateData!['nom'], 'Nouveau Nom');

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Profil mis à jour.'), findsOneWidget);
    });
  });
}
