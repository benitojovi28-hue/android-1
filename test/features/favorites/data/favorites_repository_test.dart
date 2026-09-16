import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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

  group('FavoritesRepository.favoriteCompanies', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    FavoritesRepository buildWithHttp(Future<http.Response> Function(http.Request) handler) {
      final client = SupabaseClient(
        'https://example.supabase.co',
        'anon-key',
        httpClient: MockClient(handler),
      );
      return FavoritesRepository(client, LocalFavoritesStore(prefs));
    }

    // Regression test: this used to be a single embedded-resource select
    // (`candidat_favoris` -> `entreprises`), which threw PGRST200 because
    // PostgREST can't find a direct FK between those two tables. Fetching
    // separately and joining client-side avoids that entirely.
    test('fetches favorited entreprises via two separate queries, not an embedded select', () async {
      final repo = buildWithHttp((request) async {
        if (request.url.path.endsWith('/candidat_favoris')) {
          expect(request.url.queryParameters['candidat_id'], 'eq.cand-1');
          return http.Response(
            jsonEncode([
              {'recruteur_id': 'user-a'},
              {'recruteur_id': 'user-b'},
            ]),
            200,
            request: request,
          );
        }
        if (request.url.path.endsWith('/entreprises')) {
          expect(request.url.queryParameters['user_id'], 'in.("user-a","user-b")');
          return http.Response(
            jsonEncode([
              {'id': 'ent-1', 'user_id': 'user-a', 'nom': 'Acme', 'logo_url': null, 'secteur': null, 'ville': 'Douala'},
            ]),
            200,
            request: request,
          );
        }
        return http.Response('not found', 404, request: request);
      });

      final result = await repo.favoriteCompanies('cand-1');

      expect(result, hasLength(1));
      expect(result.single['recruteur_id'], 'user-a');
      expect((result.single['entreprise'] as Map)['nom'], 'Acme');
    });

    test('returns an empty list without querying entreprises when there are no favorites', () async {
      var entreprisesQueried = false;
      final repo = buildWithHttp((request) async {
        if (request.url.path.endsWith('/candidat_favoris')) {
          return http.Response(jsonEncode(<Map<String, dynamic>>[]), 200, request: request);
        }
        if (request.url.path.endsWith('/entreprises')) {
          entreprisesQueried = true;
        }
        return http.Response('not found', 404, request: request);
      });

      expect(await repo.favoriteCompanies('cand-1'), isEmpty);
      expect(entreprisesQueried, isFalse);
    });
  });
}
