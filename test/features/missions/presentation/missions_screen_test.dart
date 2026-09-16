import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/applications/application/candidatures_providers.dart';
import 'package:mywork/features/missions/presentation/missions_screen.dart';
import 'package:mywork/models/candidature.dart';
import 'package:mywork/models/offre.dart';

import '../fakes/fake_candidatures_repository.dart';

Widget _wrap(FakeCandidaturesRepository repository) {
  return ProviderScope(
    overrides: [candidaturesRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: MissionsScreen()),
  );
}

Candidature _candidature({
  required String id,
  required String statut,
  DateTime? employeFinDeclareeAt,
  DateTime? employeurFinConfirmeeAt,
}) {
  return Candidature(
    id: id,
    createdAt: DateTime(2026, 1, 1),
    statut: statut,
    offre: const Offre(id: 'o1', titre: 'Développeur Flutter', entrepriseNom: 'Acme'),
    employeFinDeclareeAt: employeFinDeclareeAt,
    employeurFinConfirmeeAt: employeurFinConfirmeeAt,
  );
}

void main() {
  group('MissionsScreen', () {
    testWidgets('shows a loader while applications are loading', (tester) async {
      await tester.pumpWidget(_wrap(FakeCandidaturesRepository()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows the empty state when there are no accepted applications', (tester) async {
      final applications = [_candidature(id: 'c1', statut: 'envoyee')];
      await tester.pumpWidget(_wrap(FakeCandidaturesRepository(applications: applications)));
      await tester.pumpAndSettle();

      expect(find.text('Aucune mission en cours'), findsOneWidget);
    });

    testWidgets('shows an error state when loading fails', (tester) async {
      await tester.pumpWidget(
        _wrap(FakeCandidaturesRepository(applicationsError: Exception('boom'))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
    });

    testWidgets('only lists applications with statut acceptee', (tester) async {
      final applications = [
        _candidature(id: 'c1', statut: 'envoyee'),
        _candidature(id: 'c2', statut: 'refusee'),
        _candidature(id: 'c3', statut: 'acceptee'),
      ];
      await tester.pumpWidget(_wrap(FakeCandidaturesRepository(applications: applications)));
      await tester.pumpAndSettle();

      expect(find.text('Développeur Flutter'), findsOneWidget);
      expect(find.text('Acme'), findsOneWidget);
    });

    testWidgets('shows "Mission en cours" when neither end date is set', (tester) async {
      final applications = [_candidature(id: 'c1', statut: 'acceptee')];
      await tester.pumpWidget(_wrap(FakeCandidaturesRepository(applications: applications)));
      await tester.pumpAndSettle();

      expect(find.text('Mission en cours'), findsOneWidget);
    });

    testWidgets('shows "Fin déclarée" when the employee declared the end but it is unconfirmed', (tester) async {
      final applications = [
        _candidature(id: 'c1', statut: 'acceptee', employeFinDeclareeAt: DateTime(2026, 2, 1)),
      ];
      await tester.pumpWidget(_wrap(FakeCandidaturesRepository(applications: applications)));
      await tester.pumpAndSettle();

      expect(find.text('Fin déclarée, en attente de confirmation'), findsOneWidget);
    });

    testWidgets('shows "terminée et confirmée" once the employer confirms the end', (tester) async {
      final applications = [
        _candidature(
          id: 'c1',
          statut: 'acceptee',
          employeFinDeclareeAt: DateTime(2026, 2, 1),
          employeurFinConfirmeeAt: DateTime(2026, 2, 2),
        ),
      ];
      await tester.pumpWidget(_wrap(FakeCandidaturesRepository(applications: applications)));
      await tester.pumpAndSettle();

      expect(find.text('Mission terminée et confirmée'), findsOneWidget);
    });
  });
}
