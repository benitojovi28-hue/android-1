import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mywork/core/utils/local_favorites_store.dart';

/// Two distinct mechanisms — don't conflate them:
/// 1. Favorited job offers: local-only (LocalFavoritesStore), not a table.
/// 2. Favorited recruiters/companies: `candidat_favoris` table
///    (candidat_id + recruteur_id — no offre_id column at all).
class FavoritesRepository {
  FavoritesRepository(this._client, this._localStore);

  final SupabaseClient _client;
  final LocalFavoritesStore _localStore;

  List<String> favoriteOfferIds() => _localStore.getAll();

  bool isOfferFavorite(String offreId) => _localStore.isFavorite(offreId);

  Future<void> toggleOfferFavorite(String offreId) => _localStore.toggle(offreId);

  /// `recruteur_id` stores the recruiter's auth user id, and `entreprises`
  /// has no direct foreign key to `candidat_favoris` for PostgREST to embed
  /// (it only relates via `entreprises.user_id`) — so this fetches the two
  /// tables separately and joins them client-side instead of relying on an
  /// embedded-resource select, which throws PGRST200 for this pair.
  Future<List<Map<String, dynamic>>> favoriteCompanies(String candidatId) async {
    final favRows = await _client
        .from('candidat_favoris')
        .select('recruteur_id')
        .eq('candidat_id', candidatId);
    final recruteurIds = (favRows as List).map((r) => r['recruteur_id'] as String).toList();
    if (recruteurIds.isEmpty) return [];

    final entreprises = await _client
        .from('entreprises')
        .select('id,user_id,nom,logo_url,secteur,ville')
        .inFilter('user_id', recruteurIds);
    return (entreprises as List)
        .map((e) => {'recruteur_id': e['user_id'], 'entreprise': e as Map<String, dynamic>})
        .toList();
  }

  Future<void> toggleCompanyFavorite({required String candidatId, required String recruteurId}) async {
    final existing = await _client
        .from('candidat_favoris')
        .select('candidat_id')
        .eq('candidat_id', candidatId)
        .eq('recruteur_id', recruteurId)
        .maybeSingle();
    if (existing != null) {
      await _client
          .from('candidat_favoris')
          .delete()
          .eq('candidat_id', candidatId)
          .eq('recruteur_id', recruteurId);
    } else {
      await _client.from('candidat_favoris').insert({
        'candidat_id': candidatId,
        'recruteur_id': recruteurId,
      });
    }
  }
}
