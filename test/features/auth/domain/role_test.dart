import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/features/auth/domain/role.dart';

void main() {
  group('homePathForRole', () {
    test('candidat and guest land on the candidate home', () {
      expect(homePathForRole(Role.candidat), '/');
      expect(homePathForRole(Role.guest), '/');
    });

    test('entreprise lands on the company dashboard', () {
      expect(homePathForRole(Role.entreprise), '/entreprise/dashboard');
    });

    test('unknown lands on the space-chooser screen', () {
      expect(homePathForRole(Role.unknown), '/choisir-espace');
    });

    test('admin lands on the candidate home (no admin back-office in this app)', () {
      expect(homePathForRole(Role.admin), '/');
    });
  });
}
