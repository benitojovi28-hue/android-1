import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/models/service.dart';

void main() {
  group('ServiceListing.fromMap', () {
    test('parses a fully populated row', () {
      final service = ServiceListing.fromMap({
        'id': 's1',
        'titre': 'Réparation ordinateurs',
        'categorie': 'Informatique',
        'prix': 5000,
        'prix_unite': 'heure',
        'devise': 'FCFA',
        'region': 'Centre',
        'localisation': 'Yaoundé',
        'images': ['https://example.com/1.png', 'https://example.com/2.png'],
        'is_active': false,
      });

      expect(service.id, 's1');
      expect(service.titre, 'Réparation ordinateurs');
      expect(service.prix, 5000);
      expect(service.images, hasLength(2));
      expect(service.isActive, isFalse);
    });

    test('titre falls back to empty string, images and isActive default', () {
      final service = ServiceListing.fromMap({'id': 's1'});

      expect(service.titre, '');
      expect(service.images, isEmpty);
      expect(service.isActive, isTrue);
    });
  });
}
