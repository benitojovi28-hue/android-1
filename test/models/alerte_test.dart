import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/models/alerte.dart';

void main() {
  group('AlerteCandidat.fromMap', () {
    test('parses a fully populated row', () {
      final alerte = AlerteCandidat.fromMap({
        'id': 'a1',
        'libelle': 'Alerte Dev',
        'mots_cles': 'flutter,dart',
        'metier': 'Développeur',
        'secteur': 'Informatique',
        'region': 'Centre',
        'ville': 'Yaoundé',
        'type_contrat': 'CDI',
        'salaire_min': 150000,
        'actif': false,
      });

      expect(alerte.id, 'a1');
      expect(alerte.libelle, 'Alerte Dev');
      expect(alerte.motsCles, 'flutter,dart');
      expect(alerte.salaireMin, 150000);
      expect(alerte.actif, isFalse);
    });

    test('actif defaults to true when missing', () {
      final alerte = AlerteCandidat.fromMap({'id': 'a1'});
      expect(alerte.actif, isTrue);
    });
  });

  group('AlerteCandidat.toInsertMap', () {
    test('includes the candidat id and all fields', () {
      const alerte = AlerteCandidat(
        id: 'a1',
        libelle: 'Alerte Dev',
        motsCles: 'flutter',
        metier: 'Développeur',
        secteur: 'Informatique',
        region: 'Centre',
        ville: 'Yaoundé',
        typeContrat: 'CDI',
        salaireMin: 150000,
        actif: true,
      );

      final map = alerte.toInsertMap('cand-1');

      expect(map['candidat_id'], 'cand-1');
      expect(map['libelle'], 'Alerte Dev');
      expect(map['mots_cles'], 'flutter');
      expect(map['salaire_min'], 150000);
      expect(map['actif'], isTrue);
      expect(map.containsKey('id'), isFalse);
    });
  });
}
