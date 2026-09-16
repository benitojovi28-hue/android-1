import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/features/services_marketplace/application/services_providers.dart';
import 'package:mywork/features/services_marketplace/presentation/services_browse_screen.dart';
import 'package:mywork/models/service.dart';

Widget _wrap(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(home: ServicesBrowseScreen()),
  );
}

void main() {
  group('ServicesBrowseScreen', () {
    testWidgets('shows a loader while services are loading', (tester) async {
      final completer = Completer<List<ServiceListing>>();
      await tester.pumpWidget(_wrap([
        servicesBrowseProvider.overrideWith((ref) => completer.future),
      ]));
      await tester.pump();

      expect(find.byType(AppLoader), findsOneWidget);
    });

    testWidgets('shows services when data is loaded', (tester) async {
      const services = [
        ServiceListing(id: 's1', titre: 'Plomberie', categorie: 'Maison', prix: 5000, localisation: 'Douala'),
      ];
      await tester.pumpWidget(_wrap([
        servicesBrowseProvider.overrideWith((ref) async => services),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Plomberie'), findsOneWidget);
      expect(find.text('Maison'), findsOneWidget);
      expect(find.text('Douala'), findsOneWidget);
    });

    testWidgets('shows an empty state when there are no services', (tester) async {
      await tester.pumpWidget(_wrap([
        servicesBrowseProvider.overrideWith((ref) async => const []),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Aucun service disponible'), findsOneWidget);
    });

    testWidgets('shows an error state when the provider throws', (tester) async {
      await tester.pumpWidget(_wrap([
        servicesBrowseProvider.overrideWith((ref) async => throw Exception('boom')),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
    });
  });
}
