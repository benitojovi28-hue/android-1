import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/models/candidat.dart';

void main() {
  group('Candidat.fromMap', () {
    test('parses a fully populated row', () {
      final candidat = Candidat.fromMap({
        'id': 'c1',
        'user_id': 'u1',
        'nom': 'Nguema',
        'prenom': 'Alex',
        'email': 'alex@example.com',
        'telephone': '+237600000000',
        'photo_url': 'https://example.com/photo.png',
        'titre_professionnel': 'Développeur',
        'region': 'Centre',
        'ville': 'Yaoundé',
        'competences': ['Flutter', 'Dart'],
        'experience_annees': 3,
        'note_moyenne': 4.5,
        'nb_avis': 10,
        'score_completude': 80,
        'numero_public': 'PUB-1',
        'compte_statut': 'actif',
      });

      expect(candidat.id, 'c1');
      expect(candidat.userId, 'u1');
      expect(candidat.nom, 'Nguema');
      expect(candidat.prenom, 'Alex');
      expect(candidat.competences, ['Flutter', 'Dart']);
      expect(candidat.experienceAnnees, 3);
      expect(candidat.noteMoyenne, 4.5);
      expect(candidat.nbAvis, 10);
      expect(candidat.scoreCompletude, 80);
      expect(candidat.numeroPublic, 'PUB-1');
      expect(candidat.compteStatut, 'actif');
    });

    test('parses required-only fields with nulls/defaults for the rest', () {
      final candidat = Candidat.fromMap({'id': 'c1', 'user_id': 'u1'});

      expect(candidat.id, 'c1');
      expect(candidat.userId, 'u1');
      expect(candidat.nom, isNull);
      expect(candidat.prenom, isNull);
      expect(candidat.competences, isEmpty);
      expect(candidat.numeroPublic, isNull);
    });

    test('numero_public stored as an int in Postgres is coerced to String', () {
      final candidat = Candidat.fromMap({'id': 'c1', 'user_id': 'u1', 'numero_public': 12345});

      expect(candidat.numeroPublic, '12345');
    });

    test('numero_public already a String passes through unchanged', () {
      final candidat = Candidat.fromMap({'id': 'c1', 'user_id': 'u1', 'numero_public': 'PUB-9'});

      expect(candidat.numeroPublic, 'PUB-9');
    });
  });

  group('Candidat.displayName', () {
    test('joins prenom and nom with a space', () {
      const candidat = Candidat(id: 'c1', userId: 'u1', prenom: 'Alex', nom: 'Nguema');
      expect(candidat.displayName, 'Alex Nguema');
    });

    test('falls back to whichever half is present', () {
      const onlyPrenom = Candidat(id: 'c1', userId: 'u1', prenom: 'Alex');
      const onlyNom = Candidat(id: 'c1', userId: 'u1', nom: 'Nguema');
      expect(onlyPrenom.displayName, 'Alex');
      expect(onlyNom.displayName, 'Nguema');
    });

    test('is empty when neither prenom nor nom is set', () {
      const candidat = Candidat(id: 'c1', userId: 'u1');
      expect(candidat.displayName, isEmpty);
    });
  });
}
