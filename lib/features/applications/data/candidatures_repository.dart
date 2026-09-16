import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:mywork/models/candidat_cv.dart';
import 'package:mywork/models/candidature.dart';

/// Direct port of src/lib/candidatures.server.ts. That file is confirmed to
/// run as plain RLS-scoped Supabase calls (not privileged server code), so
/// this is a straight port, not a redesign.
class CandidaturesRepository {
  CandidaturesRepository(this._client);

  final SupabaseClient _client;

  static const cvBucket = 'candidate-cvs';
  static const _uuid = Uuid();

  Future<Map<String, dynamic>> _candidatOfCurrentUser() async {
    final userId = _client.auth.currentUser?.id;

    try {
      final rpcId = await _client.rpc('assurer_profil_candidat');
      if (rpcId != null) {
        final row = await _client
            .from('candidats')
            .select('id,prenom,nom,email,telephone')
            .eq('id', rpcId as String)
            .maybeSingle();
        if (row != null) return row;
      }
    } catch (_) {
      // fall through to the direct lookup below
    }

    final row = await _client
        .from('candidats')
        .select('id,prenom,nom,email,telephone')
        .eq('user_id', userId as Object)
        .maybeSingle();
    if (row == null) {
      throw Exception('Profil candidat indisponible. Reconnectez-vous puis réessayez.');
    }
    return row;
  }

  Future<List<CandidatCvFile>> myCvs() async {
    final candidat = await _candidatOfCurrentUser();
    final rows = await _client
        .from('candidat_cvs')
        .select('id,nom,fichier_url,taille,mime,par_defaut,created_at')
        .eq('candidat_id', candidat['id'] as String)
        .order('created_at', ascending: false);
    return (rows as List).map((r) => CandidatCvFile.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<void> deleteCv(String cvId) async {
    final candidat = await _candidatOfCurrentUser();
    final cv = await _client
        .from('candidat_cvs')
        .select('id,fichier_url')
        .eq('id', cvId)
        .eq('candidat_id', candidat['id'] as String)
        .maybeSingle();
    if (cv == null) throw Exception('CV introuvable');

    await _client.from('candidat_cvs').delete().eq('id', cvId).eq('candidat_id', candidat['id'] as String);
    await _client.storage.from(cvBucket).remove([cv['fichier_url'] as String]);
  }

  Future<CandidatCvFile> _uploadCv({
    required String userId,
    required String candidatId,
    required Uint8List bytes,
    required String filename,
    required String mime,
  }) async {
    if (bytes.lengthInBytes > 8 * 1024 * 1024) {
      throw Exception('Fichier trop volumineux (max 8 Mo).');
    }
    final ext = (filename.split('.').last).toLowerCase();
    final path = '$userId/cv-${_uuid.v4()}.$ext';

    await _client.storage.from(cvBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mime.isNotEmpty ? mime : 'application/pdf'),
        );

    final row = await _client
        .from('candidat_cvs')
        .insert({
          'candidat_id': candidatId,
          'nom': filename.length > 120 ? filename.substring(0, 120) : filename,
          'fichier_url': path,
          'taille': bytes.lengthInBytes,
          'mime': mime,
          'par_defaut': false,
        })
        .select('id,nom,fichier_url,taille,mime,par_defaut,created_at')
        .single();
    return CandidatCvFile.fromMap(row);
  }

  Future<CandidatCvFile> addCv({
    required Uint8List bytes,
    required String filename,
    required String mime,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final candidat = await _candidatOfCurrentUser();
    return _uploadCv(
      userId: userId,
      candidatId: candidat['id'] as String,
      bytes: bytes,
      filename: filename,
      mime: mime,
    );
  }

  /// Result keys: ok, duplicate, cvManquant, cvMyworkManquant, manquants,
  /// candidature (map with id/created_at/statut) — mirrors postulerServeur's
  /// discriminated-union-ish return shape.
  Future<Map<String, dynamic>> apply({
    required String offreId,
    String? cvId,
    bool cvNumerique = false,
    Uint8List? cvFichierBytes,
    String? cvFichierNom,
    String? cvFichierMime,
    String? message,
    String? prenom,
    String? nom,
    String? email,
    String? telephone,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final candidat = await _candidatOfCurrentUser();

    final resolvedPrenom = (prenom ?? candidat['prenom'] as String? ?? '').trim();
    final resolvedNom = (nom ?? candidat['nom'] as String? ?? '').trim();
    final resolvedEmail = (email ?? candidat['email'] as String? ?? '').trim();
    final resolvedTelephone = (telephone ?? candidat['telephone'] as String? ?? '').trim();

    final manquants = <String>[];
    if (resolvedPrenom.length < 2) manquants.add('prenom');
    if (resolvedNom.length < 2) manquants.add('nom');
    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(resolvedEmail)) manquants.add('email');
    if (resolvedTelephone.replaceAll(RegExp(r'\D'), '').length < 8) manquants.add('telephone');
    if (manquants.isNotEmpty) return {'ok': false, 'manquants': manquants};

    final offre = await _client.from('offres').select('id').eq('id', offreId).maybeSingle();
    if (offre == null) throw Exception("Cette offre n'est plus disponible.");

    final existante = await _client
        .from('candidatures')
        .select('id')
        .eq('candidat_id', candidat['id'] as String)
        .eq('offre_id', offreId)
        .maybeSingle();
    if (existante != null) {
      return {'ok': false, 'duplicate': true, 'id': existante['id']};
    }

    final candidatId = candidat['id'] as String;

    if (cvNumerique) {
      final cvNum = await _client
          .from('candidat_cv')
          .select(
            'infos,profil_pro,experiences,formations,competences,langues,extras,utiliser_photo_profil,complet,updated_at',
          )
          .eq('candidat_id', candidatId)
          .maybeSingle();
      if (cvNum == null) return {'ok': false, 'cvMyworkManquant': true};

      try {
        final inserted = await _client
            .from('candidatures')
            .insert({
              'candidat_id': candidatId,
              'offre_id': offreId,
              'cv_id': null,
              'cv_nom': 'CV MyWork',
              'cv_chemin': null,
              'cv_numerique': cvNum,
              'message': message != null && message.length > 2000 ? message.substring(0, 2000) : message,
              'candidat_nom': '$resolvedPrenom $resolvedNom'.trim(),
              'candidat_email': resolvedEmail,
              'candidat_telephone': resolvedTelephone,
              'source': 'plateforme',
              'statut': 'envoyee',
            })
            .select('id,created_at,statut')
            .single();
        return {'ok': true, 'candidature': inserted};
      } on PostgrestException catch (e) {
        if (e.message.toLowerCase().contains('duplicate') || e.message.toLowerCase().contains('unique')) {
          return {'ok': false, 'duplicate': true};
        }
        throw Exception('Enregistrement de la candidature impossible : ${e.message}');
      }
    }

    Map<String, dynamic>? cv;
    if (cvId != null) {
      cv = await _client
          .from('candidat_cvs')
          .select('id,nom,fichier_url')
          .eq('id', cvId)
          .eq('candidat_id', candidatId)
          .maybeSingle();
      if (cv == null) throw Exception('CV introuvable.');
    } else if (cvFichierBytes != null && cvFichierNom != null) {
      final uploaded = await _uploadCv(
        userId: userId,
        candidatId: candidatId,
        bytes: cvFichierBytes,
        filename: cvFichierNom,
        mime: cvFichierMime ?? 'application/pdf',
      );
      cv = {'id': uploaded.id, 'nom': uploaded.nom, 'fichier_url': uploaded.fichierUrl};
    } else {
      return {'ok': false, 'cvManquant': true};
    }

    final sourcePath = cv['fichier_url'] as String;
    final sourceExt = sourcePath.split('.').last.toLowerCase();
    final snapshotPath = '$userId/candidature-${_uuid.v4()}.$sourceExt';

    await _client.storage.from(cvBucket).copy(sourcePath, snapshotPath);

    try {
      final inserted = await _client
          .from('candidatures')
          .insert({
            'candidat_id': candidatId,
            'offre_id': offreId,
            'cv_id': cv['id'],
            'cv_nom': cv['nom'],
            'cv_chemin': snapshotPath,
            'message': message != null && message.length > 2000 ? message.substring(0, 2000) : message,
            'candidat_nom': '$resolvedPrenom $resolvedNom'.trim(),
            'candidat_email': resolvedEmail,
            'candidat_telephone': resolvedTelephone,
            'source': 'plateforme',
            'statut': 'envoyee',
          })
          .select('id,created_at,statut')
          .single();
      return {'ok': true, 'candidature': inserted};
    } on PostgrestException catch (e) {
      await _client.storage.from(cvBucket).remove([snapshotPath]);
      if (e.message.toLowerCase().contains('duplicate') || e.message.toLowerCase().contains('unique')) {
        return {'ok': false, 'duplicate': true};
      }
      throw Exception('Enregistrement de la candidature impossible : ${e.message}');
    } catch (e) {
      await _client.storage.from(cvBucket).remove([snapshotPath]);
      rethrow;
    }
  }

  Future<List<Candidature>> myApplications({DateTime? du, DateTime? au}) async {
    final candidat = await _candidatOfCurrentUser();
    var query = _client
        .from('candidatures')
        .select(
          'id,created_at,statut,message,cv_id,cv_nom,cv_chemin,cv_numerique,entretien_at,'
          'employe_fin_declaree_at,employeur_fin_confirmee_at,'
          'offre:offres(id,titre,entreprise_nom,ville,type_contrat)',
        )
        .eq('candidat_id', candidat['id'] as String);

    if (du != null) query = query.gte('created_at', du.toIso8601String());
    if (au != null) query = query.lte('created_at', au.toIso8601String());

    final rows = await query.order('created_at', ascending: false);
    final liste = (rows as List).cast<Map<String, dynamic>>();

    final chemins = liste
        .map((r) => r['cv_chemin'] as String?)
        .whereType<String>()
        .toList();

    final urls = <String, String>{};
    if (chemins.isNotEmpty) {
      final signed = await _client.storage.from(cvBucket).createSignedUrls(chemins, 3600);
      for (final s in signed) {
        urls[s.path] = s.signedUrl;
      }
    }

    return liste.map((r) {
      final chemin = r['cv_chemin'] as String?;
      final withUrl = {...r, 'cv_url': chemin != null ? urls[chemin] : null};
      return Candidature.fromMap(withUrl);
    }).toList();
  }

  Future<void> changeStatus(String candidatureId, String statut) async {
    final data = await _client.rpc('recruteur_changer_statut_candidature', params: {
      '_candidature_id': candidatureId,
      '_statut': statut,
    });
    final row = data is List ? (data.isNotEmpty ? data.first : null) : data;
    if (row == null) throw Exception('Candidature introuvable ou accès refusé.');
  }
}
