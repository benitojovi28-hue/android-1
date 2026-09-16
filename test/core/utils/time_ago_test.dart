import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/core/utils/time_ago.dart';

void main() {
  group('timeAgo', () {
    test('returns "à l\'instant" for a moment just now', () {
      expect(timeAgo(DateTime.now().subtract(const Duration(seconds: 10))), "à l'instant");
    });

    test('pluralizes minutes correctly', () {
      expect(timeAgo(DateTime.now().subtract(const Duration(minutes: 1))), 'il y a 1 minute');
      expect(timeAgo(DateTime.now().subtract(const Duration(minutes: 5))), 'il y a 5 minutes');
    });

    test('pluralizes hours correctly', () {
      expect(timeAgo(DateTime.now().subtract(const Duration(hours: 1))), 'il y a 1 heure');
      expect(timeAgo(DateTime.now().subtract(const Duration(hours: 3))), 'il y a 3 heures');
    });

    test('pluralizes days correctly', () {
      expect(timeAgo(DateTime.now().subtract(const Duration(days: 1))), 'il y a 1 jour');
      expect(timeAgo(DateTime.now().subtract(const Duration(days: 5))), 'il y a 5 jours');
    });

    test('falls back to months between 30 and 365 days', () {
      expect(timeAgo(DateTime.now().subtract(const Duration(days: 60))), 'il y a 2 mois');
    });

    test('falls back to years past 365 days', () {
      expect(timeAgo(DateTime.now().subtract(const Duration(days: 400))), 'il y a 1 an');
      expect(timeAgo(DateTime.now().subtract(const Duration(days: 800))), 'il y a 2 ans');
    });
  });
}
