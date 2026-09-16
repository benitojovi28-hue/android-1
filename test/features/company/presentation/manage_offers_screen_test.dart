import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/company/application/company_providers.dart';
import 'package:mywork/features/company/presentation/manage_offers_screen.dart';
import 'package:mywork/models/offre.dart';

void main() {
  group('ManageOffersScreen', () {
    testWidgets('shows an empty state when there are no offers', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [myOffersProvider.overrideWith((ref) async => const [])],
          child: const MaterialApp(home: ManageOffersScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aucune offre publiée'), findsOneWidget);
    });

    testWidgets('shows an error state when loading fails', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            myOffersProvider.overrideWith((ref) => Future<List<Offre>>.error(Exception('boom'))),
          ],
          child: const MaterialApp(home: ManageOffersScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
    });

    testWidgets('renders a card per offer with its title and status chip', (tester) async {
      final offers = [
        const Offre(id: 'o1', titre: 'Développeur Flutter', statut: 'actif'),
        const Offre(id: 'o2', titre: 'Comptable', statut: 'archivee'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [myOffersProvider.overrideWith((ref) async => offers)],
          child: const MaterialApp(home: ManageOffersScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Développeur Flutter'), findsOneWidget);
      expect(find.text('Comptable'), findsOneWidget);
      expect(find.text('actif'), findsOneWidget);
      expect(find.text('archivee'), findsOneWidget);
    });
  });
}
