import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mywork/core/utils/local_favorites_store.dart';
import 'package:mywork/features/favorites/data/favorites_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late FavoritesRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    // The offer-favorite methods never touch the Supabase client, so an
    // unstubbed mock is safe here — this test never calls any of its methods.
    repository = FavoritesRepository(MockSupabaseClient(), LocalFavoritesStore(prefs));
  });

  group('FavoritesRepository offer favorites (local-only)', () {
    test('favoriteOfferIds is empty by default', () {
      expect(repository.favoriteOfferIds(), isEmpty);
    });

    test('toggleOfferFavorite delegates to the local store', () async {
      expect(repository.isOfferFavorite('offre-1'), isFalse);

      await repository.toggleOfferFavorite('offre-1');
      expect(repository.isOfferFavorite('offre-1'), isTrue);
      expect(repository.favoriteOfferIds(), ['offre-1']);

      await repository.toggleOfferFavorite('offre-1');
      expect(repository.isOfferFavorite('offre-1'), isFalse);
      expect(repository.favoriteOfferIds(), isEmpty);
    });
  });
}
