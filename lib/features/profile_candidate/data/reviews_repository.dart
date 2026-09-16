import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mywork/models/avis.dart';

class ReviewsRepository {
  ReviewsRepository(this._client);

  final SupabaseClient _client;

  Future<List<Avis>> reviewsFor({required String cibleId, required String cibleType}) async {
    final rows = await _client
        .from('avis')
        .select()
        .eq('cible_id', cibleId)
        .eq('cible_type', cibleType)
        .order('created_at', ascending: false);
    return (rows as List).map((r) => Avis.fromMap(r as Map<String, dynamic>)).toList();
  }
}
