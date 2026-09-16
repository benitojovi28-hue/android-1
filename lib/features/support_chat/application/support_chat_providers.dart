import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/supabase/supabase_provider.dart';
import 'package:mywork/features/support_chat/data/support_chat_repository.dart';

final supportChatRepositoryProvider = Provider<SupportChatRepository>((ref) {
  return SupportChatRepository(ref.watch(supabaseProvider));
});

final conversationIdProvider = FutureProvider.autoDispose<String>((ref) {
  return ref.watch(supportChatRepositoryProvider).getOrCreateConversation();
});

final messagesStreamProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final conversationId = ref.watch(conversationIdProvider).valueOrNull;
  if (conversationId == null) return const Stream.empty();
  return ref.watch(supportChatRepositoryProvider).watchMessages(conversationId);
});
