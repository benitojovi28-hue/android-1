import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/applications/application/candidatures_providers.dart';
import 'package:mywork/features/applications/data/candidatures_repository.dart';
import 'package:mywork/features/applications/presentation/recruiter_applications_screen.dart';
import 'package:mywork/features/company/application/company_providers.dart';
import 'package:mywork/models/candidat_cv.dart';
import 'package:mywork/models/candidature.dart';
import 'package:mywork/models/offre.dart';

class FakeCandidaturesRepository implements CandidaturesRepository {
  final List<Map<String, String>> statusChanges = [];

  @override
  Future<void> changeStatus(String candidatureId, String statut) async {
    statusChanges.add({'id': candidatureId, 'statut': statut});
  }

  @override
  Future<CandidatCvFile> addCv({
    required Uint8List bytes,
    required String filename,
    required String mime,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCv(String cvId) {
    throw UnimplementedError();
  }

  @override
  Future<List<CandidatCvFile>> myCvs() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> apply({
    required String offreId,
    String? cvId,
    bool cvNumerique = false,
    Uint8List? cvFichierBytes,
    String? cvFichierNom,
    String? cvFichierMime,
    String? message,
    String? prenom,
    String? nom,
    String? email,
    String? telephone,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Candidature>> myApplications({DateTime? du, DateTime? au}) {
    throw UnimplementedError();
  }
}

Candidature _candidature({
  required String id,
  required String statut,
  String? candidatNom,
  String? candidatTelephone,
  Offre? offre,
}) {
  return Candidature(
    id: id,
    createdAt: DateTime(2026, 1, 1),
    statut: statut,
    candidatNom: candidatNom,
    candidatTelephone: candidatTelephone,
    offre: offre,
  );
}

void main() {
  group('RecruiterApplicationsScreen', () {
    testWidgets('shows a loader while applications are loading', (tester) async {
      final completer = Completer<List<Candidature>>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [recruiterApplicationsProvider.overrideWith((ref) => completer.future)],
          child: const MaterialApp(home: RecruiterApplicationsScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(const []);
      await tester.pumpAndSettle();
    });

    testWidgets('shows an empty state when there are no applications', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [recruiterApplicationsProvider.overrideWith((ref) async => const [])],
          child: const MaterialApp(home: RecruiterApplicationsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aucune candidature reçue'), findsOneWidget);
    });

    testWidgets('shows an error state when loading fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recruiterApplicationsProvider.overrideWith((ref) => Future<List<Candidature>>.error(Exception('boom'))),
          ],
          child: const MaterialApp(home: RecruiterApplicationsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
    });

    testWidgets('renders candidate name, offer title and a call button when a phone is present', (tester) async {
      final applications = [
        _candidature(
          id: 'c1',
          statut: 'envoyee',
          candidatNom: 'Alex Nguema',
          candidatTelephone: '+237600000000',
          offre: const Offre(id: 'o1', titre: 'Développeur Flutter'),
        ),
        _candidature(id: 'c2', statut: 'vue', candidatNom: 'Sans Téléphone'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recruiterApplicationsProvider.overrideWith((ref) async => applications),
            candidaturesRepositoryProvider.overrideWithValue(FakeCandidaturesRepository()),
          ],
          child: const MaterialApp(home: RecruiterApplicationsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alex Nguema'), findsOneWidget);
      expect(find.text('Développeur Flutter'), findsOneWidget);
      expect(find.text('Sans Téléphone'), findsOneWidget);
      expect(find.byIcon(Icons.call_outlined), findsOneWidget);
    });

    testWidgets('defaults the status dropdown to null when the stored statut is not a known option', (tester) async {
      final applications = [
        _candidature(id: 'c1', statut: 'statut_inconnu', candidatNom: 'Alex Nguema'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recruiterApplicationsProvider.overrideWith((ref) async => applications),
            candidaturesRepositoryProvider.overrideWithValue(FakeCandidaturesRepository()),
          ],
          child: const MaterialApp(home: RecruiterApplicationsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final dropdown = tester.widget<DropdownButtonFormField<String>>(find.byType(DropdownButtonFormField<String>));
      expect(dropdown.initialValue, isNull);
    });

    testWidgets('defaults the status dropdown to the stored statut when it is a known option', (tester) async {
      final applications = [
        _candidature(id: 'c1', statut: 'entretien', candidatNom: 'Alex Nguema'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recruiterApplicationsProvider.overrideWith((ref) async => applications),
            candidaturesRepositoryProvider.overrideWithValue(FakeCandidaturesRepository()),
          ],
          child: const MaterialApp(home: RecruiterApplicationsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final dropdown = tester.widget<DropdownButtonFormField<String>>(find.byType(DropdownButtonFormField<String>));
      expect(dropdown.initialValue, 'entretien');
    });

    testWidgets('changing the status dropdown calls changeStatus with the candidature id and new statut', (tester) async {
      final applications = [
        _candidature(id: 'c1', statut: 'envoyee', candidatNom: 'Alex Nguema'),
      ];
      final repo = FakeCandidaturesRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recruiterApplicationsProvider.overrideWith((ref) async => applications),
            candidaturesRepositoryProvider.overrideWithValue(repo),
          ],
          child: const MaterialApp(home: RecruiterApplicationsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('entretien').last);
      await tester.pumpAndSettle();

      expect(repo.statusChanges, [
        {'id': 'c1', 'statut': 'entretien'},
      ]);
    });
  });
}
