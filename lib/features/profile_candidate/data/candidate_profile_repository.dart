import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mywork/models/candidat.dart';

class CandidateProfileRepository {
  CandidateProfileRepository(this._client);

  final SupabaseClient _client;

  static const documentsBucket = 'candidate-documents';

  Future<Candidat?> myProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client.from('candidats').select().eq('user_id', userId).maybeSingle();
    return row != null ? Candidat.fromMap(row) : null;
  }

  Future<String?> signedPhotoUrl(String path) async {
    try {
      final signed = await _client.storage.from(documentsBucket).createSignedUrl(path, 3600);
      return signed;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProfile(String candidatId, Map<String, dynamic> changes) async {
    await _client.from('candidats').update(changes).eq('id', candidatId);
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

  Future<Map<String, dynamic>?> myCvNumerique(String candidatId) async {
    return _client
        .from('candidat_cv')
        .select()
        .eq('candidat_id', candidatId)
        .maybeSingle();
  }

  Future<void> saveCvNumerique(String candidatId, Map<String, dynamic> data) async {
    await _client.from('candidat_cv').upsert({
      'candidat_id': candidatId,
      ...data,
    }, onConflict: 'candidat_id');
  }
}
