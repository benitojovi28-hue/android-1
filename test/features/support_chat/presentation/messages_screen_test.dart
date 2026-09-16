import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/features/support_chat/application/support_chat_providers.dart';
import 'package:mywork/features/support_chat/data/support_chat_repository.dart';
import 'package:mywork/features/support_chat/presentation/messages_screen.dart';
import 'package:mywork/models/support_message.dart';

class _FakeSupportChatRepository implements SupportChatRepository {
  final List<Map<String, String>> sentMessages = [];

  @override
  Future<String> getOrCreateConversation() => throw UnimplementedError();

  @override
  Future<List<SupportMessage>> messages(String conversationId) => throw UnimplementedError();

  @override
  Future<void> sendMessage({required String conversationId, required String content}) async {
    sentMessages.add({'conversationId': conversationId, 'content': content});
  }

  @override
  Stream<List<Map<String, dynamic>>> watchMessages(String conversationId) => Stream.value(const []);
}

Widget _wrap({required List<Override> overrides}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(home: MessagesScreen()),
  );
}

void main() {
  group('MessagesScreen', () {
    testWidgets('shows a loader while messages are loading', (tester) async {
      final completer = Completer<List<Map<String, dynamic>>>();
      await tester.pumpWidget(_wrap(overrides: [
        messagesStreamProvider.overrideWith((ref) => Stream.fromFuture(completer.future)),
      ]));
      await tester.pump();

      expect(find.byType(AppLoader), findsOneWidget);
    });

    testWidgets('shows a placeholder when there are no messages', (tester) async {
      await tester.pumpWidget(_wrap(overrides: [
        messagesStreamProvider.overrideWith((ref) => Stream.value(const [])),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Écrivez-nous, nous vous répondrons rapidement.'), findsOneWidget);
    });

    testWidgets('shows an error message when the stream errors', (tester) async {
      await tester.pumpWidget(_wrap(overrides: [
        messagesStreamProvider.overrideWith((ref) => Stream.error(Exception('boom'))),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
    });

    testWidgets('renders user and agent messages with distinct alignment', (tester) async {
      final rows = [
        {
          'id': 'm1',
          'conversation_id': 'c1',
          'role': 'agent',
          'content': 'Bonjour, comment puis-je vous aider ?',
          'created_at': '2026-01-01T00:00:00.000Z',
        },
        {
          'id': 'm2',
          'conversation_id': 'c1',
          'role': 'user',
          'content': "J'ai un problème avec mon compte",
          'created_at': '2026-01-01T00:01:00.000Z',
        },
      ];
      await tester.pumpWidget(_wrap(overrides: [
        messagesStreamProvider.overrideWith((ref) => Stream.value(rows)),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Bonjour, comment puis-je vous aider ?'), findsOneWidget);
      expect(find.text("J'ai un problème avec mon compte"), findsOneWidget);

      final agentAlign = tester.widget<Align>(
        find.ancestor(of: find.text('Bonjour, comment puis-je vous aider ?'), matching: find.byType(Align)).first,
      );
      final userAlign = tester.widget<Align>(
        find.ancestor(of: find.text("J'ai un problème avec mon compte"), matching: find.byType(Align)).first,
      );
      expect(agentAlign.alignment, Alignment.centerLeft);
      expect(userAlign.alignment, Alignment.centerRight);
    });

    testWidgets('sends a message and clears the input', (tester) async {
      final repo = _FakeSupportChatRepository();
      await tester.pumpWidget(_wrap(overrides: [
        conversationIdProvider.overrideWith((ref) async => 'conv-1'),
        supportChatRepositoryProvider.overrideWithValue(repo),
      ]));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Bonjour le support');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(repo.sentMessages, [
        {'conversationId': 'conv-1', 'content': 'Bonjour le support'},
      ]);
      expect(find.text('Bonjour le support'), findsNothing);
    });
  });
}
