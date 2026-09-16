import 'dart:typed_data';

import 'package:mywork/features/applications/data/candidatures_repository.dart';
import 'package:mywork/models/candidat_cv.dart';
import 'package:mywork/models/candidature.dart';

class FakeCandidaturesRepository implements CandidaturesRepository {
  FakeCandidaturesRepository({
    this.applications = const [],
    this.cvs = const [],
    this.applicationsError,
    this.cvsError,
  });

  final List<Candidature> applications;
  final List<CandidatCvFile> cvs;
  final Object? applicationsError;
  final Object? cvsError;

  final List<String> deletedCvIds = [];

  @override
  Future<List<Candidature>> myApplications({DateTime? du, DateTime? au}) async {
    if (applicationsError != null) throw applicationsError!;
    return applications;
  }

  @override
  Future<List<CandidatCvFile>> myCvs() async {
    if (cvsError != null) throw cvsError!;
    return cvs;
  }

  @override
  Future<void> deleteCv(String cvId) async {
    deletedCvIds.add(cvId);
  }

  @override
  Future<CandidatCvFile> addCv({
    required Uint8List bytes,
    required String filename,
    required String mime,
  }) async {
    throw UnimplementedError('not needed for these tests');
  }

  @override
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
    throw UnimplementedError('not needed for these tests');
  }

  @override
  Future<void> changeStatus(String candidatureId, String statut) async {
    throw UnimplementedError('not needed for these tests');
  }
}
