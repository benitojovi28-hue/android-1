import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/services_marketplace/application/services_providers.dart';
import 'package:mywork/features/services_marketplace/data/services_repository.dart';
import 'package:mywork/features/services_marketplace/presentation/my_services_screen.dart';
import 'package:mywork/models/service.dart';

class _FakeServicesRepository implements ServicesRepository {
  _FakeServicesRepository({this.myServicesResult = const [], this.myServicesCompleter});

  List<ServiceListing> myServicesResult;
  Completer<List<ServiceListing>>? myServicesCompleter;
  final List<String> deletedIds = [];

  @override
  Future<void> createService(Map<String, dynamic> data) => throw UnimplementedError();

  @override
  Future<void> deleteService(String id) async {
    deletedIds.add(id);
  }

  @override
  Future<List<ServiceListing>> myServices(String userId) {
    if (myServicesCompleter != null) return myServicesCompleter!.future;
    return Future.value(myServicesResult);
  }

  @override
  Future<List<ServiceListing>> search({String? query, String? categorie, String? ville, String? region}) =>
      throw UnimplementedError();

  @override
  Future<void> updateService(String id, Map<String, dynamic> changes) => throw UnimplementedError();
}

const _user = User(id: 'user-1', appMetadata: {}, userMetadata: {}, aud: 'authenticated', createdAt: '');

Widget _wrap({required List<Override> overrides}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(home: MyServicesScreen()),
  );
}

void main() {
  group('MyServicesScreen', () {
    testWidgets('shows an empty state when the user has no user session', (tester) async {
      final repo = _FakeServicesRepository();
      await tester.pumpWidget(_wrap(overrides: [
        currentUserProvider.overrideWithValue(null),
        servicesRepositoryProvider.overrideWithValue(repo),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Aucun service publié'), findsOneWidget);
    });

    testWidgets('shows the user services when data is loaded', (tester) async {
      final repo = _FakeServicesRepository(
        myServicesResult: const [ServiceListing(id: 's1', titre: 'Réparation électrique')],
      );
      await tester.pumpWidget(_wrap(overrides: [
        currentUserProvider.overrideWithValue(_user),
        servicesRepositoryProvider.overrideWithValue(repo),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Réparation électrique'), findsOneWidget);
    });

    testWidgets('shows an empty state when the user has no services', (tester) async {
      final repo = _FakeServicesRepository();
      await tester.pumpWidget(_wrap(overrides: [
        currentUserProvider.overrideWithValue(_user),
        servicesRepositoryProvider.overrideWithValue(repo),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Aucun service publié'), findsOneWidget);
    });

    testWidgets('deletes a service when the delete button is tapped', (tester) async {
      final repo = _FakeServicesRepository(
        myServicesResult: const [ServiceListing(id: 's1', titre: 'Réparation électrique')],
      );
      await tester.pumpWidget(_wrap(overrides: [
        currentUserProvider.overrideWithValue(_user),
        servicesRepositoryProvider.overrideWithValue(repo),
      ]));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(repo.deletedIds, ['s1']);
    });

    testWidgets('shows a loader while services are loading', (tester) async {
      final repo = _FakeServicesRepository(myServicesCompleter: Completer<List<ServiceListing>>());
      await tester.pumpWidget(_wrap(overrides: [
        currentUserProvider.overrideWithValue(_user),
        servicesRepositoryProvider.overrideWithValue(repo),
      ]));
      await tester.pump();

      expect(find.byType(AppLoader), findsOneWidget);
    });
  });
}
