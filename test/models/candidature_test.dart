import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/models/candidature.dart';

void main() {
  group('Candidature.fromMap', () {
    test('parses a fully populated row including a nested offre', () {
      final candidature = Candidature.fromMap({
        'id': 'cand1',
        'created_at': '2026-01-01T00:00:00.000Z',
        'statut': 'en_cours',
        'message': 'Bonjour',
        'cv_id': 'cv1',
        'cv_nom': 'Mon CV.pdf',
        'cv_chemin': '/cvs/mon-cv.pdf',
        'cv_url': 'https://example.com/mon-cv.pdf',
        'cv_numerique': {'competences': ['Flutter']},
        'entretien_at': '2026-01-05T10:00:00.000Z',
        'candidat_nom': 'Alex Nguema',
        'candidat_email': 'alex@example.com',
        'candidat_telephone': '+237600000000',
        'offre': {'id': 'o1', 'titre': 'Développeur Flutter'},
        'employe_fin_declaree_at': '2026-02-01T00:00:00.000Z',
        'employeur_fin_confirmee_at': '2026-02-02T00:00:00.000Z',
      });

      expect(candidature.id, 'cand1');
      expect(candidature.createdAt, DateTime.parse('2026-01-01T00:00:00.000Z'));
      expect(candidature.statut, 'en_cours');
      expect(candidature.usesCvNumerique, isTrue);
      expect(candidature.offre?.id, 'o1');
      expect(candidature.offre?.titre, 'Développeur Flutter');
      expect(candidature.entretienAt, DateTime.parse('2026-01-05T10:00:00.000Z'));
    });

    test('statut defaults to envoyee and offre/cv_numerique default to null', () {
      final candidature = Candidature.fromMap({
        'id': 'cand1',
        'created_at': '2026-01-01T00:00:00.000Z',
      });

      expect(candidature.statut, 'envoyee');
      expect(candidature.usesCvNumerique, isFalse);
      expect(candidature.offre, isNull);
    });

    test('throws when created_at is missing (required field)', () {
      expect(
        () => Candidature.fromMap({'id': 'cand1'}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
