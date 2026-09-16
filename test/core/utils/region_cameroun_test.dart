import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/core/utils/region_cameroun.dart';

void main() {
  group('RegionCameroun', () {
    test('has exactly 10 values matching the Postgres enum', () {
      expect(RegionCameroun.values, hasLength(10));
    });

    test('dbValue matches the expected Postgres string for each enum value', () {
      expect(RegionCameroun.adamaoua.dbValue, 'Adamaoua');
      expect(RegionCameroun.extremeNord.dbValue, 'Extreme-Nord');
      expect(RegionCameroun.nordOuest.dbValue, 'Nord-Ouest');
      expect(RegionCameroun.sudOuest.dbValue, 'Sud-Ouest');
    });
  });

  group('RegionCameroun.fromDb', () {
    test('resolves a known db value to the matching enum member', () {
      expect(RegionCameroun.fromDb('Centre'), RegionCameroun.centre);
      expect(RegionCameroun.fromDb('Sud-Ouest'), RegionCameroun.sudOuest);
    });

    test('returns null for an unknown value', () {
      expect(RegionCameroun.fromDb('Not A Region'), isNull);
    });

    test('returns null for a null input', () {
      expect(RegionCameroun.fromDb(null), isNull);
    });
  });
}
