import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/company/application/company_providers.dart';
import 'package:mywork/features/company/presentation/dashboard_screen.dart';
import 'package:mywork/models/candidature.dart';
import 'package:mywork/models/entreprise.dart';
import 'package:mywork/models/offre.dart';

const _entreprise = Entreprise(id: 'ent1', userId: 'user1', nom: 'Acme Corp', verificationStatut: 'verifie');

void main() {
  group('CompanyDashboardScreen', () {
    testWidgets('counts only offers with statut "actif" in the "Offres actives" stat card', (tester) async {
      final offers = [
        const Offre(id: 'o1', titre: 'Poste 1', statut: 'actif'),
        const Offre(id: 'o2', titre: 'Poste 2', statut: 'actif'),
        const Offre(id: 'o3', titre: 'Poste 3', statut: 'archivee'),
        const Offre(id: 'o4', titre: 'Poste 4', statut: 'expiree'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myCompanyProvider.overrideWith((ref) async => _entreprise),
            myOffersProvider.overrideWith((ref) async => offers),
            recruiterApplicationsProvider.overrideWith((ref) async => const []),
          ],
          child: const MaterialApp(home: CompanyDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Offres actives'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows the total application count in the "Candidatures" stat card', (tester) async {
      final applications = [
        Candidature(id: 'c1', createdAt: DateTime(2026, 1, 1), statut: 'envoyee'),
        Candidature(id: 'c2', createdAt: DateTime(2026, 1, 2), statut: 'vue'),
        Candidature(id: 'c3', createdAt: DateTime(2026, 1, 3), statut: 'entretien'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myCompanyProvider.overrideWith((ref) async => _entreprise),
            myOffersProvider.overrideWith((ref) async => const []),
            recruiterApplicationsProvider.overrideWith((ref) async => applications),
          ],
          child: const MaterialApp(home: CompanyDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Candidatures'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('treats offers and applications as empty while they are still loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myCompanyProvider.overrideWith((ref) async => _entreprise),
            myOffersProvider.overrideWith((ref) => Completer<List<Offre>>().future),
            recruiterApplicationsProvider.overrideWith((ref) => Completer<List<Candidature>>().future),
          ],
          child: const MaterialApp(home: CompanyDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Acme Corp'), findsOneWidget);
      expect(find.text('0'), findsNWidgets(2));
    });

    testWidgets('shows the company name and verification status', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myCompanyProvider.overrideWith((ref) async => _entreprise),
            myOffersProvider.overrideWith((ref) async => const []),
            recruiterApplicationsProvider.overrideWith((ref) async => const []),
          ],
          child: const MaterialApp(home: CompanyDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Acme Corp'), findsOneWidget);
      expect(find.text('verifie'), findsOneWidget);
    });

    testWidgets('shows a loader while the company profile is loading', (tester) async {
      final completer = Completer<Entreprise?>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [myCompanyProvider.overrideWith((ref) => completer.future)],
          child: const MaterialApp(home: CompanyDashboardScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(_entreprise);
      await tester.pumpAndSettle();
    });

    testWidgets('shows a message when the company profile could not be found', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [myCompanyProvider.overrideWith((ref) async => null)],
          child: const MaterialApp(home: CompanyDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profil entreprise introuvable'), findsOneWidget);
    });

    testWidgets('shows an error message when the company profile fails to load', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myCompanyProvider.overrideWith((ref) => Future<Entreprise?>.error(Exception('boom'))),
          ],
          child: const MaterialApp(home: CompanyDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
    });
  });
}
