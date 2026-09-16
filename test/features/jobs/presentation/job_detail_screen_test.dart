import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/favorites/application/favorites_providers.dart';
import 'package:mywork/features/favorites/data/favorites_repository.dart';
import 'package:mywork/features/jobs/application/offres_providers.dart';
import 'package:mywork/features/jobs/presentation/job_detail_screen.dart';
import 'package:mywork/models/offre.dart';

class FakeFavoritesRepository implements FavoritesRepository {
  bool favorite = false;

  @override
  List<String> favoriteOfferIds() => favorite ? ['offre-1'] : [];

  @override
  bool isOfferFavorite(String offreId) => favorite;

  @override
  Future<void> toggleOfferFavorite(String offreId) async => favorite = !favorite;

  @override
  Future<List<Map<String, dynamic>>> favoriteCompanies(String candidatId) async => [];

  @override
  Future<void> toggleCompanyFavorite({required String candidatId, required String recruteurId}) async {}
}

void main() {
  Future<void> pumpDetail(WidgetTester tester, Offre? offre) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          offreDetailProvider.overrideWith((ref, id) async => offre),
          currentUserProvider.overrideWithValue(null),
          favoritesRepositoryProvider.overrideWithValue(FakeFavoritesRepository()),
        ],
        child: const MaterialApp(home: JobDetailScreen(offreId: 'offre-1')),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  group('JobDetailScreen description rendering', () {
    testWidgets('renders normal HTML content', (tester) async {
      final offre = Offre(
        id: 'offre-1',
        titre: 'Développeur',
        description: '<p>Une belle <b>opportunité</b> à Douala.</p>',
      );

      await pumpDetail(tester, offre);

      expect(find.text('Description non disponible pour cette offre.'), findsNothing);
      expect(find.text('Aucune description fournie.'), findsNothing);
    });

    testWidgets('falls back to "non disponible" for truncated/malformed HTML', (tester) async {
      final offre = Offre(
        id: 'offre-1',
        titre: 'Développeur',
        description: '<a href="http://example.com/foo',
      );

      await pumpDetail(tester, offre);

      expect(find.text('Description non disponible pour cette offre.'), findsOneWidget);
    });

    testWidgets('shows a plain message when the description is null', (tester) async {
      final offre = Offre(id: 'offre-1', titre: 'Développeur');

      await pumpDetail(tester, offre);

      expect(find.text('Aucune description fournie.'), findsOneWidget);
      expect(find.text('Description non disponible pour cette offre.'), findsNothing);
    });

    testWidgets('shows a plain message when the description is blank', (tester) async {
      final offre = Offre(id: 'offre-1', titre: 'Développeur', description: '   ');

      await pumpDetail(tester, offre);

      expect(find.text('Aucune description fournie.'), findsOneWidget);
    });
  });

  testWidgets('shows an empty state when the offer is not found', (tester) async {
    await pumpDetail(tester, null);

    expect(find.text('Offre introuvable'), findsOneWidget);
  });
}
