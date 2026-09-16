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

  Future<List<Map<String, dynamic>>> favoriteCompanies(String candidatId) async {
    final rows = await _client
        .from('candidat_favoris')
        .select('recruteur_id, entreprise:entreprises(id,nom,logo_url,secteur,ville)')
        .eq('candidat_id', candidatId);
    return (rows as List).cast<Map<String, dynamic>>();
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
