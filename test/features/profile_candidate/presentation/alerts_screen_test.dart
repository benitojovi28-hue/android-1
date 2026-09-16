import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/profile_candidate/application/profile_providers.dart';
import 'package:mywork/features/profile_candidate/presentation/alerts_screen.dart';
import 'package:mywork/models/alerte.dart';
import 'package:mywork/models/candidat.dart';

import '../fakes/fake_repositories.dart';

const _profile = Candidat(id: 'c1', userId: 'u1', prenom: 'Alex', nom: 'Nguema');

Widget _wrap({
  required FakeAlertsRepository alertsRepository,
  FakeCandidateProfileRepository? profileRepository,
}) {
  return ProviderScope(
    overrides: [
      candidateProfileRepositoryProvider.overrideWithValue(
        profileRepository ?? FakeCandidateProfileRepository(profile: _profile),
      ),
      alertsRepositoryProvider.overrideWithValue(alertsRepository),
    ],
    child: const MaterialApp(home: AlertsScreen()),
  );
}

void main() {
  group('AlertsScreen', () {
    testWidgets('shows a loader while alerts are loading', (tester) async {
      await tester.pumpWidget(_wrap(alertsRepository: FakeAlertsRepository()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows the empty state when there are no alerts', (tester) async {
      await tester.pumpWidget(_wrap(alertsRepository: FakeAlertsRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Aucune alerte'), findsOneWidget);
    });

    testWidgets('shows an error state when loading fails', (tester) async {
      await tester.pumpWidget(
        _wrap(alertsRepository: FakeAlertsRepository(alertsError: Exception('boom'))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
    });

    testWidgets('renders each alert with its active state', (tester) async {
      const alerts = [
        AlerteCandidat(id: 'a1', libelle: 'Alerte Dev', actif: true),
        AlerteCandidat(id: 'a2', libelle: 'Alerte Compta', actif: false),
      ];
      await tester.pumpWidget(_wrap(alertsRepository: FakeAlertsRepository(alerts: alerts)));
      await tester.pumpAndSettle();

      expect(find.text('Alerte Dev'), findsOneWidget);
      expect(find.text('Alerte Compta'), findsOneWidget);

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches, hasLength(2));
      expect(switches[0].value, isTrue);
      expect(switches[1].value, isFalse);
    });

    testWidgets('falls back to mots-clés when an alert has no libellé', (tester) async {
      const alerts = [AlerteCandidat(id: 'a1', motsCles: 'flutter,dart')];
      await tester.pumpWidget(_wrap(alertsRepository: FakeAlertsRepository(alerts: alerts)));
      await tester.pumpAndSettle();

      expect(find.text('flutter,dart'), findsOneWidget);
    });

    testWidgets('toggling the switch calls setActive on the repository', (tester) async {
      const alerts = [AlerteCandidat(id: 'a1', libelle: 'Alerte Dev', actif: true)];
      final repository = FakeAlertsRepository(alerts: alerts);
      await tester.pumpWidget(_wrap(alertsRepository: repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(repository.setActiveCalls, ['a1:false']);
    });

    testWidgets('tapping delete calls deleteAlert on the repository', (tester) async {
      const alerts = [AlerteCandidat(id: 'a1', libelle: 'Alerte Dev')];
      final repository = FakeAlertsRepository(alerts: alerts);
      await tester.pumpWidget(_wrap(alertsRepository: repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(repository.deleteCalls, ['a1']);
    });
  });
}
