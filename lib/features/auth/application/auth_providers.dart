import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mywork/core/supabase/supabase_provider.dart';
import 'package:mywork/features/auth/data/auth_repository.dart';
import 'package:mywork/features/auth/data/role_repository.dart';
import 'package:mywork/features/auth/domain/role.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseProvider));
});

final roleRepositoryProvider = Provider<RoleRepository>((ref) {
  return RoleRepository(ref.watch(supabaseProvider));
});

/// Streams every auth state transition (SIGNED_IN, SIGNED_OUT, USER_UPDATED, ...).
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// The current Supabase user, derived from the latest auth state (or the
/// already-persisted session on cold start, before the first event fires).
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).valueOrNull;
  return authState?.session?.user ?? ref.watch(supabaseProvider).auth.currentUser;
});

/// Resolves the effective Role for the current user by calling the database
/// (RPC + fallback) — re-resolved whenever the user identity changes.
final roleProvider = FutureProvider<Role>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Role.guest;

  final roleRepo = ref.watch(roleRepositoryProvider);
  final role = await roleRepo.fetchAccountRole(user.id);

  if (role == Role.candidat) {
    await roleRepo.ensureCandidatProfile();
  } else if (role == Role.entreprise) {
    await roleRepo.ensureEntrepriseProfile();
  }

  return role;
});
