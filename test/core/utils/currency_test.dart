import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mywork/core/utils/currency.dart';

void main() {
  // fr_FR groups thousands with a locale-specific space character (not a
  // plain ASCII space) — derive expectations from the same formatter the
  // source uses instead of hardcoding a literal that could be the wrong
  // whitespace character.
  String fcfa(num amount) => '${NumberFormat.decimalPattern('fr_FR').format(amount)} FCFA';

  group('formatFcfa', () {
    test('formats a positive amount with FCFA suffix', () {
      expect(formatFcfa(150000), fcfa(150000));
    });

    test('returns an em dash for null', () {
      expect(formatFcfa(null), '—');
    });

    test('formats zero', () {
      expect(formatFcfa(0), fcfa(0));
    });
  });

  group('formatSalaryRange', () {
    test('prefers a free-text value when provided', () {
      expect(formatSalaryRange(min: 100000, max: 200000, texte: 'Selon profil'), 'Selon profil');
    });

    test('ignores a blank free-text value', () {
      expect(formatSalaryRange(min: 100000, max: 200000, texte: '   '), '${fcfa(100000)} - ${fcfa(200000)}');
    });

    test('formats a min-max range', () {
      expect(formatSalaryRange(min: 100000, max: 200000), '${fcfa(100000)} - ${fcfa(200000)}');
    });

    test('formats a min-only value', () {
      expect(formatSalaryRange(min: 100000), 'À partir de ${fcfa(100000)}');
    });

    test('formats a max-only value', () {
      expect(formatSalaryRange(max: 200000), "Jusqu'à ${fcfa(200000)}");
    });

    test('falls back to a generic message when nothing is provided', () {
      expect(formatSalaryRange(), 'Salaire non précisé');
    });
  });
}
