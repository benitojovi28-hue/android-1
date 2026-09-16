import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mywork/models/service.dart';

class ServicesRepository {
  ServicesRepository(this._client);

  final SupabaseClient _client;

  Future<List<ServiceListing>> search({
    String? query,
    String? categorie,
    String? ville,
    String? region,
  }) async {
    final rows = await _client.rpc('rechercher_services', params: {
      '_q': query,
      '_categorie': categorie,
      '_ville': ville,
      '_region': region,
    });
    return (rows as List).map((r) => ServiceListing.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<List<ServiceListing>> myServices(String userId) async {
    final rows = await _client
        .from('services')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (rows as List).map((r) => ServiceListing.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<void> createService(Map<String, dynamic> data) async {
    await _client.from('services').insert(data);
  }

  Future<void> updateService(String id, Map<String, dynamic> changes) async {
    await _client.from('services').update(changes).eq('id', id);
  }

  Future<void> deleteService(String id) async {
    await _client.from('services').delete().eq('id', id);
  }
}
