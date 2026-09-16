import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/favorites/application/favorites_providers.dart';
import 'package:mywork/features/favorites/data/favorites_repository.dart';
import 'package:mywork/features/favorites/presentation/favorites_screen.dart';
import 'package:mywork/features/jobs/application/offres_providers.dart';
import 'package:mywork/features/jobs/data/offres_repository.dart';
import 'package:mywork/features/jobs/presentation/widgets/offre_card.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';
import 'package:mywork/models/offre.dart';

class FakeFavoritesRepository implements FavoritesRepository {
  FakeFavoritesRepository(this.ids);

  final List<String> ids;

  @override
  List<String> favoriteOfferIds() => ids;

  @override
  bool isOfferFavorite(String offreId) => ids.contains(offreId);

  @override
  Future<void> toggleOfferFavorite(String offreId) async {}

  @override
  Future<List<Map<String, dynamic>>> favoriteCompanies(String candidatId) async => [];

  @override
  Future<void> toggleCompanyFavorite({required String candidatId, required String recruteurId}) async {}
}

class FakeOffresRepository implements OffresRepository {
  FakeOffresRepository(this.byId);

  final Map<String, Offre> byId;

  @override
  Future<List<Offre>> search(OffresSearchFilters filters, {int offset = 0}) async => [];

  @override
  Future<Offre?> getById(String id) async => byId[id];
}

void main() {
  Future<void> pumpFavorites(
    WidgetTester tester, {
    required List<String> favoriteIds,
    required Map<String, Offre> offersById,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesRepositoryProvider.overrideWithValue(FakeFavoritesRepository(favoriteIds)),
          offresRepositoryProvider.overrideWithValue(FakeOffresRepository(offersById)),
          myCandidateProfileProvider.overrideWith((ref) => Future.value(null)),
        ],
        child: const MaterialApp(home: FavoritesScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('shows an empty state when there are no favorite offers', (tester) async {
    await pumpFavorites(tester, favoriteIds: const [], offersById: const {});

    expect(find.text('Aucune offre favorite'), findsOneWidget);
    expect(find.byType(OffreCard), findsNothing);
  });

  testWidgets('lists the favorited offers', (tester) async {
    final offers = {
      'offre-1': const Offre(id: 'offre-1', titre: 'Développeur Flutter'),
      'offre-2': const Offre(id: 'offre-2', titre: 'Comptable'),
    };

    await pumpFavorites(tester, favoriteIds: ['offre-1', 'offre-2'], offersById: offers);

    expect(find.byType(OffreCard), findsNWidgets(2));
    expect(find.text('Développeur Flutter'), findsOneWidget);
    expect(find.text('Comptable'), findsOneWidget);
  });

  testWidgets('shows an empty state when favorited ids no longer resolve to offers', (tester) async {
    await pumpFavorites(tester, favoriteIds: ['missing-offer'], offersById: const {});

    expect(find.text('Aucune offre favorite'), findsOneWidget);
  });
}
