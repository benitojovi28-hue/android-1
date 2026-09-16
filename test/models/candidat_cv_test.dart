import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/models/candidat_cv.dart';

void main() {
  group('CandidatCvFile.fromMap', () {
    test('parses a fully populated row', () {
      final cv = CandidatCvFile.fromMap({
        'id': 'cv1',
        'nom': 'Mon CV.pdf',
        'fichier_url': 'https://example.com/cv.pdf',
        'taille': 102400,
        'mime': 'application/pdf',
        'par_defaut': true,
        'created_at': '2026-01-01T00:00:00.000Z',
      });

      expect(cv.id, 'cv1');
      expect(cv.nom, 'Mon CV.pdf');
      expect(cv.fichierUrl, 'https://example.com/cv.pdf');
      expect(cv.taille, 102400);
      expect(cv.mime, 'application/pdf');
      expect(cv.parDefaut, isTrue);
      expect(cv.createdAt, DateTime.parse('2026-01-01T00:00:00.000Z'));
    });

    test('nom falls back to "CV" and par_defaut defaults to false', () {
      final cv = CandidatCvFile.fromMap({'id': 'cv1', 'fichier_url': 'https://example.com/cv.pdf'});

      expect(cv.nom, 'CV');
      expect(cv.parDefaut, isFalse);
      expect(cv.taille, isNull);
      expect(cv.createdAt, isNull);
    });
  });
}
