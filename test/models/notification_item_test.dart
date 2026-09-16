import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/models/notification_item.dart';

void main() {
  group('NotificationItem.fromMap', () {
    test('parses a fully populated row', () {
      final item = NotificationItem.fromMap({
        'id': 'n1',
        'type': 'candidature',
        'titre': 'Nouvelle candidature',
        'message': 'Vous avez une nouvelle candidature.',
        'lien': '/mes-candidatures',
        'lu': true,
        'created_at': '2026-01-01T00:00:00.000Z',
        'action_requise': true,
      });

      expect(item.id, 'n1');
      expect(item.type, 'candidature');
      expect(item.titre, 'Nouvelle candidature');
      expect(item.lu, isTrue);
      expect(item.actionRequise, isTrue);
      expect(item.createdAt, DateTime.parse('2026-01-01T00:00:00.000Z'));
    });

    test('lu and actionRequise default to false when missing', () {
      final item = NotificationItem.fromMap({'id': 'n1'});

      expect(item.lu, isFalse);
      expect(item.actionRequise, isFalse);
      expect(item.createdAt, isNull);
    });
  });
}
