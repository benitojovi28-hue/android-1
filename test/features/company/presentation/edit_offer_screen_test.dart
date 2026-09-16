import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:mywork/features/company/application/company_providers.dart';
import 'package:mywork/features/company/data/company_repository.dart';
import 'package:mywork/features/company/presentation/edit_offer_screen.dart';
import 'package:mywork/features/jobs/application/offres_providers.dart';
import 'package:mywork/models/candidature.dart';
import 'package:mywork/models/entreprise.dart';
import 'package:mywork/models/offre.dart';

class FakeCompanyRepository implements CompanyRepository {
  Map<String, dynamic>? lastCreateData;
  String? lastUpdateId;
  Map<String, dynamic>? lastUpdateData;
  String? lastArchivedId;

  @override
  Future<Offre> createOffer(Map<String, dynamic> data) async {
    lastCreateData = data;
    return Offre.fromMap({...data, 'id': 'new-offer'});
  }

  @override
  Future<void> updateOffer(String id, Map<String, dynamic> changes) async {
    lastUpdateId = id;
    lastUpdateData = changes;
  }

  @override
  Future<void> archiveOffer(String id) async {
    lastArchivedId = id;
  }

  @override
  Future<Entreprise?> myCompany() {
    throw UnimplementedError();
  }

  @override
  Future<void> updateCompany(String entrepriseId, Map<String, dynamic> changes) {
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
  Future<List<Candidature>> applicationsForOffer(String offreId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Candidature>> allApplications(String entrepriseId) {
    throw UnimplementedError();
  }
}

const _entreprise = Entreprise(id: 'ent1', userId: 'user1', nom: 'Acme Corp');
const _existingOffre = Offre(
  id: 'o1',
  titre: 'Développeur Flutter',
  description: 'Une description',
  ville: 'Douala',
  region: 'Littoral',
  typeContrat: 'CDI',
  salaireMin: 200000,
  salaireMax: 400000,
  statut: 'actif',
);

Widget wrap(Widget child, {required FakeCompanyRepository repo}) {
  return ProviderScope(
    overrides: [
      companyRepositoryProvider.overrideWithValue(repo),
      myCompanyProvider.overrideWith((ref) async => _entreprise),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('EditOfferScreen create mode', () {
    testWidgets('shows the create-mode title, submit label, and no archive action', (tester) async {
      final repo = FakeCompanyRepository();
      await tester.pumpWidget(wrap(const EditOfferScreen(), repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('Nouvelle offre'), findsOneWidget);
      expect(find.text("Publier l'offre"), findsOneWidget);
      expect(find.text('Archiver cette offre'), findsNothing);
    });

    testWidgets('submits a new offer with statut "actif" and the current company id/name', (tester) async {
      // Wrapped in a minimal GoRouter because _save() calls context.pop() on
      // success; a plain MaterialApp has no GoRouter ancestor for that to find.
      final repo = FakeCompanyRepository();
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const SizedBox()),
          GoRoute(path: '/edit', builder: (context, state) => const EditOfferScreen()),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            companyRepositoryProvider.overrideWithValue(repo),
            myCompanyProvider.overrideWith((ref) async => _entreprise),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      router.push('/edit');
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Titre du poste'), 'Comptable');
      final submitButton = find.byType(ElevatedButton);
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump();

      expect(repo.lastCreateData, isNotNull);
      expect(repo.lastCreateData!['titre'], 'Comptable');
      expect(repo.lastCreateData!['statut'], 'actif');
      expect(repo.lastCreateData!['entreprise_id'], 'ent1');
      expect(repo.lastCreateData!['entreprise_nom'], 'Acme Corp');
    });
  });

  group('EditOfferScreen edit mode', () {
    testWidgets('shows the edit-mode title, save label, and the archive action', (tester) async {
      final repo = FakeCompanyRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            companyRepositoryProvider.overrideWithValue(repo),
            myCompanyProvider.overrideWith((ref) async => _entreprise),
            offreDetailProvider('o1').overrideWith((ref) async => _existingOffre),
          ],
          child: const MaterialApp(home: EditOfferScreen(offreId: 'o1')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Modifier l'offre"), findsOneWidget);
      expect(find.text('Enregistrer'), findsOneWidget);
      expect(find.text('Archiver cette offre'), findsOneWidget);
    });

    testWidgets('pre-fills the form fields from the loaded offer', (tester) async {
      final repo = FakeCompanyRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            companyRepositoryProvider.overrideWithValue(repo),
            myCompanyProvider.overrideWith((ref) async => _entreprise),
            offreDetailProvider('o1').overrideWith((ref) async => _existingOffre),
          ],
          child: const MaterialApp(home: EditOfferScreen(offreId: 'o1')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Développeur Flutter'), findsOneWidget);
      expect(find.text('Une description'), findsOneWidget);
      expect(find.text('Douala'), findsOneWidget);
      expect(find.text('200000'), findsOneWidget);
      expect(find.text('400000'), findsOneWidget);
    });
  });
}
