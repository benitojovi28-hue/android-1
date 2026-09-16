import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/models/offre.dart';

void main() {
  group('Offre.fromMap', () {
    test('parses a fully populated row', () {
      final offre = Offre.fromMap({
        'id': 'o1',
        'entreprise_id': 'e1',
        'titre': 'Développeur Flutter',
        'description': '<p>Description</p>',
        'entreprise_nom': 'Acme SARL',
        'secteur': 'Informatique',
        'categorie': 'Tech',
        'type_contrat': 'CDI',
        'region': 'Centre',
        'ville': 'Yaoundé',
        'quartier': 'Bastos',
        'salaire_min': 200000,
        'salaire_max': 400000,
        'salaire_texte': null,
        'devise': 'FCFA',
        'experience_texte': '2 ans minimum',
        'date_publication': '2026-01-01T00:00:00.000Z',
        'date_expiration': '2026-02-01T00:00:00.000Z',
        'statut': 'actif',
        'nombre_postes': 2,
      });

      expect(offre.id, 'o1');
      expect(offre.titre, 'Développeur Flutter');
      expect(offre.salaireMin, 200000);
      expect(offre.salaireMax, 400000);
      expect(offre.datePublication, DateTime.parse('2026-01-01T00:00:00.000Z'));
      expect(offre.dateExpiration, DateTime.parse('2026-02-01T00:00:00.000Z'));
      expect(offre.statut, 'actif');
      expect(offre.nombrePostes, 2);
    });

    test('titre falls back to an empty string when missing', () {
      final offre = Offre.fromMap({'id': 'o1'});

      expect(offre.titre, '');
      expect(offre.description, isNull);
      expect(offre.datePublication, isNull);
    });

    test('unparsable date strings become null instead of throwing', () {
      final offre = Offre.fromMap({'id': 'o1', 'titre': 'X', 'date_publication': 'not-a-date'});

      expect(offre.datePublication, isNull);
    });
  });
}
