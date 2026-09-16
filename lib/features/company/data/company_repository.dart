import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mywork/models/candidature.dart';
import 'package:mywork/models/entreprise.dart';
import 'package:mywork/models/offre.dart';

class CompanyRepository {
  CompanyRepository(this._client);

  final SupabaseClient _client;

  static const documentsBucket = 'entreprise-documents';

  Future<Entreprise?> myCompany() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client.from('entreprises').select().eq('user_id', userId).maybeSingle();
    return row != null ? Entreprise.fromMap(row) : null;
  }

  Future<void> updateCompany(String entrepriseId, Map<String, dynamic> changes) async {
    await _client.from('entreprises').update(changes).eq('id', entrepriseId);
  }

  Future<String> uploadDocument({
    required String folderId,
    required String filename,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final ext = filename.split('.').last.toLowerCase();
    final path = '$folderId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from(documentsBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );
    return path;
  }

  Future<List<Offre>> myOffers(String entrepriseId) async {
    final rows = await _client
        .from('offres')
        .select()
        .eq('entreprise_id', entrepriseId)
        .order('date_publication', ascending: false);
    return (rows as List).map((r) => Offre.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<Offre> createOffer(Map<String, dynamic> data) async {
    final row = await _client.from('offres').insert(data).select().single();
    return Offre.fromMap(row);
  }

  Future<void> updateOffer(String id, Map<String, dynamic> changes) async {
    await _client.from('offres').update(changes).eq('id', id);
  }

  Future<void> archiveOffer(String id) async {
    await _client.from('offres').update({'statut': 'archivee'}).eq('id', id);
  }

  Future<List<Candidature>> applicationsForOffer(String offreId) async {
    final rows = await _client
        .from('candidatures')
        .select()
        .eq('offre_id', offreId)
        .order('created_at', ascending: false);
    return (rows as List).map((r) => Candidature.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<List<Candidature>> allApplications(String entrepriseId) async {
    final rows = await _client
        .from('candidatures')
        .select('*, offre:offres!inner(id,titre,entreprise_nom,ville,type_contrat,entreprise_id)')
        .eq('offre.entreprise_id', entrepriseId)
        .order('created_at', ascending: false);
    return (rows as List).map((r) => Candidature.fromMap(r as Map<String, dynamic>)).toList();
  }
}
