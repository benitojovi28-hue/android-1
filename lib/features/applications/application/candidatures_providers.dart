import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/supabase/supabase_provider.dart';
import 'package:mywork/models/candidat_cv.dart';
import 'package:mywork/models/candidature.dart';
import 'package:mywork/features/applications/data/candidatures_repository.dart';

final candidaturesRepositoryProvider = Provider<CandidaturesRepository>((ref) {
  return CandidaturesRepository(ref.watch(supabaseProvider));
});

final myApplicationsProvider = FutureProvider.autoDispose<List<Candidature>>((ref) {
  return ref.watch(candidaturesRepositoryProvider).myApplications();
});

final myCvsProvider = FutureProvider.autoDispose<List<CandidatCvFile>>((ref) {
  return ref.watch(candidaturesRepositoryProvider).myCvs();
});
