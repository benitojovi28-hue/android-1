import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mywork/features/auth/domain/role.dart';

/// Direct port of fetchAccountRole/fetchEspaces from the web app's
/// src/hooks/useAuth.tsx. Role is NEVER trusted from JWT claims — it is
/// always re-resolved from the database via RPC (with a table fallback).
class RoleRepository {
  RoleRepository(this._client);

  final SupabaseClient _client;

  Future<Role> fetchAccountRole(String userId) async {
    try {
      final resolved = await _client.rpc('mon_espace_compte');
      if (resolved == 'admin') return Role.admin;
      if (resolved == 'entreprise') return Role.entreprise;
      if (resolved == 'candidat') return Role.candidat;
    } catch (_) {
      // fall through to the table-based fallback below
    }

    try {
      final roles = await _client.from('user_roles').select('role').eq('user_id', userId);
      final list = (roles as List).map((r) => r['role'] as String).toList();
      if (list.contains('admin')) return Role.admin;
      if (list.contains('recruteur')) return Role.entreprise;
      if (list.contains('user')) return Role.candidat;
      return Role.unknown;
    } catch (_) {
      return Role.unknown;
    }
  }

  /// Auto-provisions a `candidats` row for this user if one doesn't exist yet
  /// (mirrors chargerProfil()'s automatic linking — never asked of the user).
  Future<String?> ensureCandidatProfile() async {
    try {
      final result = await _client.rpc('assurer_profil_candidat');
      return result as String?;
    } catch (_) {
      return null;
    }
  }

  /// Auto-provisions an `entreprises` row for this user if one doesn't exist
  /// yet — the entreprise counterpart of [ensureCandidatProfile].
  Future<String?> ensureEntrepriseProfile() async {
    try {
      final result = await _client.rpc('assurer_profil_entreprise');
      return result as String?;
    } catch (_) {
      return null;
    }
  }
}
