import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/jobs/presentation/widgets/offre_card.dart';
import 'package:mywork/models/offre.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('OffreCard', () {
    testWidgets('renders all optional fields when present', (tester) async {
      final offre = Offre(
        id: 'offre-1',
        titre: 'Développeur Flutter',
        entrepriseNom: 'Acme SARL',
        ville: 'Douala',
        typeContrat: 'CDI',
        salaireMin: 100000,
        salaireMax: 200000,
        datePublication: DateTime.now().subtract(const Duration(days: 1)),
      );

      await tester.pumpWidget(wrap(OffreCard(offre: offre)));

      expect(find.text('Développeur Flutter'), findsOneWidget);
      expect(find.text('Acme SARL'), findsOneWidget);
      expect(find.text('Douala'), findsOneWidget);
      expect(find.text('CDI'), findsOneWidget);
    });

    testWidgets('omits optional rows when fields are null', (tester) async {
      const offre = Offre(id: 'offre-2', titre: 'Comptable');

      await tester.pumpWidget(wrap(OffreCard(offre: offre)));

      expect(find.text('Comptable'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsNothing);
      expect(find.byIcon(Icons.work_outline), findsNothing);
    });

    testWidgets('renders trailing widget when provided', (tester) async {
      const offre = Offre(id: 'offre-3', titre: 'Designer');

      await tester.pumpWidget(
        wrap(OffreCard(offre: offre, trailing: const Icon(Icons.star))),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('invokes onTap when tapped', (tester) async {
      const offre = Offre(id: 'offre-4', titre: 'Chef de projet');
      var tapped = false;

      await tester.pumpWidget(
        wrap(OffreCard(offre: offre, onTap: () => tapped = true)),
      );
      await tester.tap(find.byType(OffreCard));

      expect(tapped, isTrue);
    });
  });
}
