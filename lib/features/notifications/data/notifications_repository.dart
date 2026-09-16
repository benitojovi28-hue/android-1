import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mywork/features/auth/domain/role.dart';
import 'package:mywork/models/notification_item.dart';

/// Branches on the active role: notifications_candidat vs entreprise_notifications
/// — two separate tables, there is no unified notifications table.
class NotificationsRepository {
  NotificationsRepository(this._client);

  final SupabaseClient _client;

  Future<List<NotificationItem>> fetch({
    required Role role,
    required String ownerId,
  }) async {
    final table = role == Role.entreprise ? 'entreprise_notifications' : 'notifications_candidat';
    final ownerColumn = role == Role.entreprise ? 'entreprise_id' : 'candidat_id';

    final rows = await _client
        .from(table)
        .select()
        .eq(ownerColumn, ownerId)
        .order('created_at', ascending: false);
    return (rows as List).map((r) => NotificationItem.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<void> markAsRead({required Role role, required String id}) async {
    final table = role == Role.entreprise ? 'entreprise_notifications' : 'notifications_candidat';
    await _client.from(table).update({'lu': true}).eq('id', id);
  }

  Stream<List<Map<String, dynamic>>> watch({required Role role, required String ownerId}) {
    final table = role == Role.entreprise ? 'entreprise_notifications' : 'notifications_candidat';
    final ownerColumn = role == Role.entreprise ? 'entreprise_id' : 'candidat_id';
    return _client
        .from(table)
        .stream(primaryKey: ['id'])
        .eq(ownerColumn, ownerId)
        .order('created_at', ascending: false);
  }
}
