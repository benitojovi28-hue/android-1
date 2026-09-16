import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mywork/models/offre.dart';

class OffresSearchFilters {
  const OffresSearchFilters({
    this.query,
    this.region,
    this.ville,
    this.typeContrat,
    this.secteur,
  });

  final String? query;
  final String? region;
  final String? ville;
  final String? typeContrat;
  final String? secteur;

  OffresSearchFilters copyWith({
    String? query,
    String? region,
    String? ville,
    String? typeContrat,
    String? secteur,
  }) {
    return OffresSearchFilters(
      query: query ?? this.query,
      region: region ?? this.region,
      ville: ville ?? this.ville,
      typeContrat: typeContrat ?? this.typeContrat,
      secteur: secteur ?? this.secteur,
    );
  }
}

class OffresRepository {
  OffresRepository(this._client);

  final SupabaseClient _client;

  static const int pageSize = 20;

  Future<List<Offre>> search(OffresSearchFilters filters, {int offset = 0}) async {
    var query = _client.from('offres').select().eq('statut', 'actif');

    if (filters.query != null && filters.query!.trim().isNotEmpty) {
      final q = filters.query!.trim();
      query = query.or('titre.ilike.%$q%,description.ilike.%$q%,entreprise_nom.ilike.%$q%');
    }
    if (filters.region != null) query = query.eq('region', filters.region!);
    if (filters.ville != null) query = query.ilike('ville', '%${filters.ville}%');
    if (filters.typeContrat != null) query = query.eq('type_contrat', filters.typeContrat!);
    if (filters.secteur != null) query = query.eq('secteur', filters.secteur!);

    final rows = await query
        .order('date_publication', ascending: false)
        .range(offset, offset + pageSize - 1);

    return (rows as List).map((r) => Offre.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<Offre?> getById(String id) async {
    final row = await _client.from('offres').select().eq('id', id).maybeSingle();
    if (row == null) return null;
    return Offre.fromMap(row);
  }
}
