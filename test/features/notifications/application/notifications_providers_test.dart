import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/auth/domain/role.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/company/application/company_providers.dart';
import 'package:mywork/features/notifications/application/notifications_providers.dart';
import 'package:mywork/features/notifications/data/notifications_repository.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';
import 'package:mywork/models/candidat.dart';
import 'package:mywork/models/entreprise.dart';
import 'package:mywork/models/notification_item.dart';

class _FakeNotificationsRepository implements NotificationsRepository {
  _FakeNotificationsRepository({this.items = const [], this.error});

  final List<NotificationItem> items;
  final Object? error;
  final List<Role> fetchedRoles = [];
  final List<String> fetchedOwnerIds = [];

  @override
  Future<List<NotificationItem>> fetch({required Role role, required String ownerId}) async {
    fetchedRoles.add(role);
    fetchedOwnerIds.add(ownerId);
    if (error != null) throw error!;
    return items;
  }

  @override
  Future<void> markAsRead({required Role role, required String id}) => throw UnimplementedError();

  @override
  Stream<List<Map<String, dynamic>>> watch({required Role role, required String ownerId}) =>
      throw UnimplementedError();
}

const _candidat = Candidat(id: 'cand-1', userId: 'user-1');
const _entreprise = Entreprise(id: 'ent-1', userId: 'user-2');

void main() {
  group('notificationsProvider', () {
    test('candidat role with a profile fetches candidat notifications', () async {
      final items = [const NotificationItem(id: 'n1', titre: 'Hello')];
      final repo = _FakeNotificationsRepository(items: items);
      final container = ProviderContainer(
        overrides: [
          roleProvider.overrideWith((ref) async => Role.candidat),
          myCandidateProfileProvider.overrideWith((ref) async => _candidat),
          notificationsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(notificationsProvider.future);

      expect(result, items);
      expect(repo.fetchedRoles, [Role.candidat]);
      expect(repo.fetchedOwnerIds, ['cand-1']);
    });

    test('entreprise role with a company fetches entreprise notifications', () async {
      final items = [const NotificationItem(id: 'n2', titre: 'Company update')];
      final repo = _FakeNotificationsRepository(items: items);
      final container = ProviderContainer(
        overrides: [
          roleProvider.overrideWith((ref) async => Role.entreprise),
          myCompanyProvider.overrideWith((ref) async => _entreprise),
          notificationsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(notificationsProvider.future);

      expect(result, items);
      expect(repo.fetchedRoles, [Role.entreprise]);
      expect(repo.fetchedOwnerIds, ['ent-1']);
    });

    test('null candidate profile short-circuits to an empty list without calling the repository', () async {
      final repo = _FakeNotificationsRepository();
      final container = ProviderContainer(
        overrides: [
          roleProvider.overrideWith((ref) async => Role.candidat),
          myCandidateProfileProvider.overrideWith((ref) async => null),
          notificationsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(notificationsProvider.future);

      expect(result, isEmpty);
      expect(repo.fetchedRoles, isEmpty);
    });

    test('null company short-circuits to an empty list without calling the repository', () async {
      final repo = _FakeNotificationsRepository();
      final container = ProviderContainer(
        overrides: [
          roleProvider.overrideWith((ref) async => Role.entreprise),
          myCompanyProvider.overrideWith((ref) async => null),
          notificationsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(notificationsProvider.future);

      expect(result, isEmpty);
      expect(repo.fetchedRoles, isEmpty);
    });

    test('repository errors propagate as an AsyncError', () async {
      final repo = _FakeNotificationsRepository(error: Exception('boom'));
      final container = ProviderContainer(
        overrides: [
          roleProvider.overrideWith((ref) async => Role.candidat),
          myCandidateProfileProvider.overrideWith((ref) async => _candidat),
          notificationsRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(notificationsProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(notificationsProvider), isA<AsyncError>());
    });
  });
}
