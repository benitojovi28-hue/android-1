import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mywork/models/support_message.dart';

/// Wraps support_conversations/support_messages — the AI-assisted desk the
/// web app's chat UI and /contact form actually use (not the older
/// chat_conversations/chat_messages tables).
class SupportChatRepository {
  SupportChatRepository(this._client);

  final SupabaseClient _client;

  Future<String> getOrCreateConversation() async {
    final userId = _client.auth.currentUser!.id;
    final existing = await _client
        .from('support_conversations')
        .select('id')
        .eq('user_id', userId)
        .not('status', 'eq', 'closed')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (existing != null) return existing['id'] as String;

    final created = await _client
        .from('support_conversations')
        .insert({'user_id': userId, 'status': 'ai_active'})
        .select('id')
        .single();
    return created['id'] as String;
  }

  Future<List<SupportMessage>> messages(String conversationId) async {
    final rows = await _client
        .from('support_messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at');
    return (rows as List).map((r) => SupportMessage.fromMap(r as Map<String, dynamic>)).toList();
  }

  Future<void> sendMessage({required String conversationId, required String content}) async {
    await _client.from('support_messages').insert({
      'conversation_id': conversationId,
      'role': 'user',
      'content': content,
    });
  }

  Stream<List<Map<String, dynamic>>> watchMessages(String conversationId) {
    return _client
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at');
  }
}
