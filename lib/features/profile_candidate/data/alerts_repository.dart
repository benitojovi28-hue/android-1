import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mywork/models/alerte.dart';

class AlertsRepository {
  AlertsRepository(this._client);

  final SupabaseClient _client;

  Future<List<AlerteCandidat>> myAlerts(String candidatId) async {
    final rows = await _client
        .from('alertes_candidat')
        .select()
        .eq('candidat_id', candidatId)
        .order('created_at', ascending: false);
    return (rows as List).map((r) => AlerteCandidat.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<void> createAlert(AlerteCandidat alerte, String candidatId) async {
    await _client.from('alertes_candidat').insert(alerte.toInsertMap(candidatId));
  }

  Future<void> setActive(String id, bool actif) async {
    await _client.from('alertes_candidat').update({'actif': actif}).eq('id', id);
  }

  Future<void> deleteAlert(String id) async {
    await _client.from('alertes_candidat').delete().eq('id', id);
  }
}
