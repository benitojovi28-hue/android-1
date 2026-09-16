import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/models/support_message.dart';

void main() {
  group('SupportMessage.fromMap', () {
    test('parses a fully populated row', () {
      final message = SupportMessage.fromMap({
        'id': 'm1',
        'conversation_id': 'conv1',
        'role': 'assistant',
        'content': 'Bonjour, comment puis-je vous aider ?',
        'created_at': '2026-01-01T00:00:00.000Z',
      });

      expect(message.id, 'm1');
      expect(message.conversationId, 'conv1');
      expect(message.role, 'assistant');
      expect(message.content, 'Bonjour, comment puis-je vous aider ?');
      expect(message.createdAt, DateTime.parse('2026-01-01T00:00:00.000Z'));
      expect(message.isFromUser, isFalse);
    });

    test('role defaults to user and content defaults to empty string', () {
      final message = SupportMessage.fromMap({
        'id': 'm1',
        'conversation_id': 'conv1',
        'created_at': '2026-01-01T00:00:00.000Z',
      });

      expect(message.role, 'user');
      expect(message.content, '');
      expect(message.isFromUser, isTrue);
    });

    test('throws when created_at is missing (required field)', () {
      expect(
        () => SupportMessage.fromMap({'id': 'm1', 'conversation_id': 'conv1'}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
