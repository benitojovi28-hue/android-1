import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/supabase/supabase_provider.dart';
import 'package:mywork/models/alerte.dart';
import 'package:mywork/models/avis.dart';
import 'package:mywork/models/candidat.dart';
import 'package:mywork/features/profile_candidate/data/alerts_repository.dart';
import 'package:mywork/features/profile_candidate/data/candidate_profile_repository.dart';
import 'package:mywork/features/profile_candidate/data/reviews_repository.dart';

final candidateProfileRepositoryProvider = Provider<CandidateProfileRepository>((ref) {
  return CandidateProfileRepository(ref.watch(supabaseProvider));
});

final myCandidateProfileProvider = FutureProvider.autoDispose<Candidat?>((ref) {
  return ref.watch(candidateProfileRepositoryProvider).myProfile();
});

final alertsRepositoryProvider = Provider<AlertsRepository>((ref) {
  return AlertsRepository(ref.watch(supabaseProvider));
});

final myAlertsProvider = FutureProvider.autoDispose<List<AlerteCandidat>>((ref) async {
  final profile = await ref.watch(myCandidateProfileProvider.future);
  if (profile == null) return const [];
  return ref.watch(alertsRepositoryProvider).myAlerts(profile.id);
});

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepository(ref.watch(supabaseProvider));
});

final myReviewsProvider = FutureProvider.autoDispose<List<Avis>>((ref) async {
  final profile = await ref.watch(myCandidateProfileProvider.future);
  if (profile == null) return const [];
  return ref.watch(reviewsRepositoryProvider).reviewsFor(cibleId: profile.id, cibleType: 'candidat');
});
