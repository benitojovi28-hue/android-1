import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mywork/core/utils/local_favorites_store.dart';

void main() {
  late LocalFavoritesStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    store = LocalFavoritesStore(prefs);
  });

  group('LocalFavoritesStore', () {
    test('getAll is empty by default', () {
      expect(store.getAll(), isEmpty);
    });

    test('toggle adds an id, isFavorite reflects it, toggle again removes it', () async {
      expect(store.isFavorite('offre-1'), isFalse);

      await store.toggle('offre-1');
      expect(store.isFavorite('offre-1'), isTrue);
      expect(store.getAll(), ['offre-1']);

      await store.toggle('offre-1');
      expect(store.isFavorite('offre-1'), isFalse);
      expect(store.getAll(), isEmpty);
    });

    test('newly favorited ids are inserted at the front', () async {
      await store.toggle('offre-1');
      await store.toggle('offre-2');

      expect(store.getAll(), ['offre-2', 'offre-1']);
    });

    test('caps stored entries at 200', () async {
      for (var i = 0; i < 201; i++) {
        await store.toggle('offre-$i');
      }

      expect(store.getAll(), hasLength(200));
      // The most recently added entry is kept; the oldest (offre-0) is dropped.
      expect(store.getAll().first, 'offre-200');
      expect(store.getAll().contains('offre-0'), isFalse);
    });
  });
}
