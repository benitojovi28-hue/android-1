import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/auth/data/role_repository.dart';
import 'package:mywork/features/auth/domain/role.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _FakeRoleRepository implements RoleRepository {
  _FakeRoleRepository({
    this.accountRole = Role.unknown,
    this.fetchAccountRoleError,
  });

  final Role accountRole;
  final Object? fetchAccountRoleError;

  int ensureCandidatProfileCalls = 0;
  int ensureEntrepriseProfileCalls = 0;

  @override
  Future<Role> fetchAccountRole(String userId) async {
    if (fetchAccountRoleError != null) throw fetchAccountRoleError!;
    return accountRole;
  }

  @override
  Future<String?> ensureCandidatProfile() async {
    ensureCandidatProfileCalls++;
    return 'candidat-1';
  }

  @override
  Future<String?> ensureEntrepriseProfile() async {
    ensureEntrepriseProfileCalls++;
    return 'entreprise-1';
  }
}

User _fakeUser(String id) {
  return User(
    id: id,
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: DateTime(2024).toIso8601String(),
  );
}

void main() {
  group('roleProvider', () {
    test('returns guest without calling the role repository when there is no user', () async {
      final fakeRoleRepo = _FakeRoleRepository(accountRole: Role.candidat);
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          roleRepositoryProvider.overrideWithValue(fakeRoleRepo),
        ],
      );
      addTearDown(container.dispose);

      final role = await container.read(roleProvider.future);

      expect(role, Role.guest);
      expect(fakeRoleRepo.ensureCandidatProfileCalls, 0);
      expect(fakeRoleRepo.ensureEntrepriseProfileCalls, 0);
    });

    test('ensures the candidat profile when the resolved role is candidat', () async {
      final fakeRoleRepo = _FakeRoleRepository(accountRole: Role.candidat);
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(_fakeUser('u1')),
          roleRepositoryProvider.overrideWithValue(fakeRoleRepo),
        ],
      );
      addTearDown(container.dispose);

      final role = await container.read(roleProvider.future);

      expect(role, Role.candidat);
      expect(fakeRoleRepo.ensureCandidatProfileCalls, 1);
      expect(fakeRoleRepo.ensureEntrepriseProfileCalls, 0);
    });

    test('ensures the entreprise profile when the resolved role is entreprise', () async {
      final fakeRoleRepo = _FakeRoleRepository(accountRole: Role.entreprise);
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(_fakeUser('u1')),
          roleRepositoryProvider.overrideWithValue(fakeRoleRepo),
        ],
      );
      addTearDown(container.dispose);

      final role = await container.read(roleProvider.future);

      expect(role, Role.entreprise);
      expect(fakeRoleRepo.ensureCandidatProfileCalls, 0);
      expect(fakeRoleRepo.ensureEntrepriseProfileCalls, 1);
    });

    test('does not provision any profile when the resolved role is unknown or admin', () async {
      for (final role in [Role.unknown, Role.admin]) {
        final fakeRoleRepo = _FakeRoleRepository(accountRole: role);
        final container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWithValue(_fakeUser('u1')),
            roleRepositoryProvider.overrideWithValue(fakeRoleRepo),
          ],
        );
        addTearDown(container.dispose);

        final resolved = await container.read(roleProvider.future);

        expect(resolved, role);
        expect(fakeRoleRepo.ensureCandidatProfileCalls, 0);
        expect(fakeRoleRepo.ensureEntrepriseProfileCalls, 0);
      }
    });

    test('propagates an error from fetchAccountRole as an AsyncError', () async {
      final fakeRoleRepo = _FakeRoleRepository(fetchAccountRoleError: Exception('network down'));
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(_fakeUser('u1')),
          roleRepositoryProvider.overrideWithValue(fakeRoleRepo),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(container.read(roleProvider.future), throwsA(isException));
    });
  });
}
