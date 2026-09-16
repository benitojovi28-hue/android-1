import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/local/shared_preferences_provider.dart';
import 'package:mywork/core/supabase/supabase_provider.dart';
import 'package:mywork/core/utils/local_favorites_store.dart';
import 'package:mywork/features/favorites/data/favorites_repository.dart';

final localFavoritesStoreProvider = Provider<LocalFavoritesStore>((ref) {
  return LocalFavoritesStore(ref.watch(sharedPreferencesProvider));
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.watch(supabaseProvider), ref.watch(localFavoritesStoreProvider));
});

/// Bump to force widgets watching favorite status to rebuild after a toggle.
final favoritesVersionProvider = StateProvider<int>((ref) => 0);

final favoriteCompaniesProvider =
    FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, candidatId) {
  ref.watch(favoritesVersionProvider);
  return ref.watch(favoritesRepositoryProvider).favoriteCompanies(candidatId);
});
