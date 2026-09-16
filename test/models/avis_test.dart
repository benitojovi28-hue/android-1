import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/models/avis.dart';

void main() {
  group('Avis.fromMap', () {
    test('parses a fully populated row', () {
      final avis = Avis.fromMap({
        'id': 'r1',
        'note': 4.5,
        'commentaire': 'Excellent',
        'created_at': '2026-01-01T00:00:00.000Z',
      });

      expect(avis.id, 'r1');
      expect(avis.note, 4.5);
      expect(avis.commentaire, 'Excellent');
      expect(avis.createdAt, DateTime.parse('2026-01-01T00:00:00.000Z'));
    });

    test('parses required-only fields with nulls for the rest', () {
      final avis = Avis.fromMap({'id': 'r1'});

      expect(avis.id, 'r1');
      expect(avis.note, isNull);
      expect(avis.commentaire, isNull);
      expect(avis.createdAt, isNull);
    });
  });
}
