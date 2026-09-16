import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/applications/application/candidatures_providers.dart';
import 'package:mywork/features/applications/presentation/my_applications_screen.dart';
import 'package:mywork/models/candidature.dart';
import 'package:mywork/models/offre.dart';

Candidature _candidature({required String id, required String statut, Offre? offre}) {
  return Candidature(
    id: id,
    createdAt: DateTime(2026, 1, 1),
    statut: statut,
    offre: offre,
  );
}

void main() {
  group('MyApplicationsScreen', () {
    testWidgets('shows a loader while applications are loading', (tester) async {
      final completer = Completer<List<Candidature>>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [myApplicationsProvider.overrideWith((ref) => completer.future)],
          child: const MaterialApp(home: MyApplicationsScreen()),
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
          overrides: [myApplicationsProvider.overrideWith((ref) async => const [])],
          child: const MaterialApp(home: MyApplicationsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aucune candidature'), findsOneWidget);
    });

    testWidgets('shows an error state when loading fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myApplicationsProvider.overrideWith((ref) => Future<List<Candidature>>.error(Exception('boom'))),
          ],
          child: const MaterialApp(home: MyApplicationsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
    });

    testWidgets('renders a card per application with its title and status', (tester) async {
      final applications = [
        _candidature(
          id: 'c1',
          statut: 'envoyee',
          offre: const Offre(id: 'o1', titre: 'Développeur Flutter', entrepriseNom: 'Acme'),
        ),
        _candidature(id: 'c2', statut: 'entretien'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [myApplicationsProvider.overrideWith((ref) async => applications)],
          child: const MaterialApp(home: MyApplicationsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Développeur Flutter'), findsOneWidget);
      expect(find.text('Acme'), findsOneWidget);
      expect(find.text('envoyee'), findsOneWidget);
      expect(find.text('entretien'), findsOneWidget);
      expect(find.text('Offre'), findsOneWidget);
    });
  });
}
