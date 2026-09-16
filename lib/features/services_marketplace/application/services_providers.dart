import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/supabase/supabase_provider.dart';
import 'package:mywork/models/service.dart';
import 'package:mywork/features/services_marketplace/data/services_repository.dart';

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepository(ref.watch(supabaseProvider));
});

final servicesBrowseProvider = FutureProvider.autoDispose<List<ServiceListing>>((ref) {
  return ref.watch(servicesRepositoryProvider).search();
});
