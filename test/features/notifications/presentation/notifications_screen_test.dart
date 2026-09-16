import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/features/notifications/application/notifications_providers.dart';
import 'package:mywork/features/notifications/presentation/notifications_screen.dart';
import 'package:mywork/models/notification_item.dart';

Widget _wrap(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(home: NotificationsScreen()),
  );
}

void main() {
  group('NotificationsScreen', () {
    testWidgets('shows a loader while notifications are loading', (tester) async {
      final completer = Completer<List<NotificationItem>>();
      await tester.pumpWidget(_wrap([
        notificationsProvider.overrideWith((ref) => completer.future),
      ]));
      await tester.pump();

      expect(find.byType(AppLoader), findsOneWidget);
    });

    testWidgets('shows notifications when data is loaded', (tester) async {
      final items = [
        const NotificationItem(id: 'n1', titre: 'Nouvelle candidature', message: 'Un candidat a postulé'),
        const NotificationItem(id: 'n2', titre: 'Offre publiée', lu: true),
      ];
      await tester.pumpWidget(_wrap([
        notificationsProvider.overrideWith((ref) async => items),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Nouvelle candidature'), findsOneWidget);
      expect(find.text('Un candidat a postulé'), findsOneWidget);
      expect(find.text('Offre publiée'), findsOneWidget);
    });

    testWidgets('shows an empty state when there are no notifications', (tester) async {
      await tester.pumpWidget(_wrap([
        notificationsProvider.overrideWith((ref) async => const []),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Aucune notification'), findsOneWidget);
    });

    testWidgets('shows an error state when the provider throws', (tester) async {
      await tester.pumpWidget(_wrap([
        notificationsProvider.overrideWith((ref) async => throw Exception('network down')),
      ]));
      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
    });
  });
}
