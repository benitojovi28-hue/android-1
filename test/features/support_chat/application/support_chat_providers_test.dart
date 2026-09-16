import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/support_chat/application/support_chat_providers.dart';
import 'package:mywork/features/support_chat/data/support_chat_repository.dart';
import 'package:mywork/models/support_message.dart';

class _FakeSupportChatRepository implements SupportChatRepository {
  _FakeSupportChatRepository({this.watchStream});

  Stream<List<Map<String, dynamic>>>? watchStream;
  final List<String> watchedConversationIds = [];

  @override
  Future<String> getOrCreateConversation() => throw UnimplementedError();

  @override
  Future<List<SupportMessage>> messages(String conversationId) => throw UnimplementedError();

  @override
  Future<void> sendMessage({required String conversationId, required String content}) =>
      throw UnimplementedError();

  @override
  Stream<List<Map<String, dynamic>>> watchMessages(String conversationId) {
    watchedConversationIds.add(conversationId);
    return watchStream ?? const Stream.empty();
  }
}

void main() {
  group('messagesStreamProvider', () {
    test('streams messages from the repository once the conversation id resolves', () async {
      final rows = [
        {'id': 'm1', 'content': 'hello'},
      ];
      final repo = _FakeSupportChatRepository(watchStream: Stream.value(rows));
      final container = ProviderContainer(
        overrides: [
          conversationIdProvider.overrideWith((ref) async => 'conv-1'),
          supportChatRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      final sub = container.listen(messagesStreamProvider, (previous, next) {});
      addTearDown(sub.close);

      final result = await container.read(messagesStreamProvider.future);

      expect(result, rows);
      expect(repo.watchedConversationIds, ['conv-1']);
    });

    test('stays loading and never calls the repository while the conversation id has not resolved', () async {
      final repo = _FakeSupportChatRepository();
      final container = ProviderContainer(
        overrides: [
          conversationIdProvider.overrideWith((ref) => Completer<String>().future),
          supportChatRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      container.listen(messagesStreamProvider, (previous, next) {});
      await Future<void>.delayed(Duration.zero);

      expect(container.read(messagesStreamProvider), const AsyncValue<List<Map<String, dynamic>>>.loading());
      expect(repo.watchedConversationIds, isEmpty);
    });
  });
}
