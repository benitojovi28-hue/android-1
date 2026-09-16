import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/supabase/supabase_provider.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/auth/domain/role.dart';
import 'package:mywork/features/company/application/company_providers.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';
import 'package:mywork/models/notification_item.dart';
import 'package:mywork/features/notifications/data/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(supabaseProvider));
});

final notificationsProvider = FutureProvider.autoDispose<List<NotificationItem>>((ref) async {
  final role = await ref.watch(roleProvider.future);
  final repo = ref.watch(notificationsRepositoryProvider);

  if (role == Role.entreprise) {
    final company = await ref.watch(myCompanyProvider.future);
    if (company == null) return const [];
    return repo.fetch(role: role, ownerId: company.id);
  }

  final profile = await ref.watch(myCandidateProfileProvider.future);
  if (profile == null) return const [];
  return repo.fetch(role: Role.candidat, ownerId: profile.id);
});
