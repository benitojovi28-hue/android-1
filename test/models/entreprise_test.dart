import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/models/entreprise.dart';

void main() {
  group('Entreprise.fromMap', () {
    test('parses a fully populated row', () {
      final entreprise = Entreprise.fromMap({
        'id': 'e1',
        'user_id': 'u1',
        'nom': 'Acme SARL',
        'email': 'contact@acme.cm',
        'telephone': '+237600000000',
        'logo_url': 'https://example.com/logo.png',
        'secteur': 'Informatique',
        'region': 'Littoral',
        'ville': 'Douala',
        'description': 'Une entreprise.',
        'verification_statut': 'verifiee',
        'numero_public': 'PUB-1',
        'compte_statut': 'actif',
      });

      expect(entreprise.id, 'e1');
      expect(entreprise.userId, 'u1');
      expect(entreprise.nom, 'Acme SARL');
      expect(entreprise.numeroPublic, 'PUB-1');
      expect(entreprise.compteStatut, 'actif');
    });

    test('parses required-only fields with nulls for the rest', () {
      final entreprise = Entreprise.fromMap({'id': 'e1', 'user_id': 'u1'});

      expect(entreprise.id, 'e1');
      expect(entreprise.userId, 'u1');
      expect(entreprise.nom, isNull);
      expect(entreprise.numeroPublic, isNull);
    });

    test('numero_public stored as an int in Postgres is coerced to String', () {
      final entreprise = Entreprise.fromMap({'id': 'e1', 'user_id': 'u1', 'numero_public': 4242});

      expect(entreprise.numeroPublic, '4242');
    });

    test('numero_public already a String passes through unchanged', () {
      final entreprise = Entreprise.fromMap({'id': 'e1', 'user_id': 'u1', 'numero_public': 'PUB-9'});

      expect(entreprise.numeroPublic, 'PUB-9');
    });
  });
}
