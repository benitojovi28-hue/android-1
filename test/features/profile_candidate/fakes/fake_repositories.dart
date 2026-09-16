import 'dart:typed_data';

import 'package:mywork/features/profile_candidate/data/alerts_repository.dart';
import 'package:mywork/features/profile_candidate/data/candidate_profile_repository.dart';
import 'package:mywork/features/profile_candidate/data/reviews_repository.dart';
import 'package:mywork/models/alerte.dart';
import 'package:mywork/models/avis.dart';
import 'package:mywork/models/candidat.dart';

class FakeCandidateProfileRepository implements CandidateProfileRepository {
  FakeCandidateProfileRepository({this.profile, this.profileError});

  final Candidat? profile;
  final Object? profileError;

  String? lastUpdatedCandidatId;
  Map<String, dynamic>? lastUpdatedChanges;
  Map<String, dynamic>? cvNumerique;

  @override
  Future<Candidat?> myProfile() async {
    if (profileError != null) throw profileError!;
    return profile;
  }

  @override
  Future<String?> signedPhotoUrl(String path) async => null;

  @override
  Future<void> updateProfile(String candidatId, Map<String, dynamic> changes) async {
    lastUpdatedCandidatId = candidatId;
    lastUpdatedChanges = changes;
  }

  @override
  Future<String> uploadDocument({
    required String folderId,
    required String filename,
    required Uint8List bytes,
    required String contentType,
  }) async {
    return '$folderId/$filename';
  }

  @override
  Future<Map<String, dynamic>?> myCvNumerique(String candidatId) async => cvNumerique;

  @override
  Future<void> saveCvNumerique(String candidatId, Map<String, dynamic> data) async {
    cvNumerique = {...?cvNumerique, ...data};
  }
}

class FakeAlertsRepository implements AlertsRepository {
  FakeAlertsRepository({this.alerts = const [], this.alertsError});

  final List<AlerteCandidat> alerts;
  final Object? alertsError;

  final List<String> setActiveCalls = [];
  final List<String> deleteCalls = [];
  AlerteCandidat? createdAlert;
  String? createdForCandidatId;

  @override
  Future<List<AlerteCandidat>> myAlerts(String candidatId) async {
    if (alertsError != null) throw alertsError!;
    return alerts;
  }

  @override
  Future<void> createAlert(AlerteCandidat alerte, String candidatId) async {
    createdAlert = alerte;
    createdForCandidatId = candidatId;
  }

  @override
  Future<void> setActive(String id, bool actif) async {
    setActiveCalls.add('$id:$actif');
  }

  @override
  Future<void> deleteAlert(String id) async {
    deleteCalls.add(id);
  }
}

class FakeReviewsRepository implements ReviewsRepository {
  FakeReviewsRepository({this.reviews = const [], this.reviewsError});

  final List<Avis> reviews;
  final Object? reviewsError;

  @override
  Future<List<Avis>> reviewsFor({required String cibleId, required String cibleType}) async {
    if (reviewsError != null) throw reviewsError!;
    return reviews;
  }
}
