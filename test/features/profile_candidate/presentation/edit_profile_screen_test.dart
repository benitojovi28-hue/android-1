import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/profile_candidate/application/profile_providers.dart';
import 'package:mywork/features/profile_candidate/presentation/edit_profile_screen.dart';
import 'package:mywork/models/candidat.dart';

import '../fakes/fake_repositories.dart';

Widget _wrap(FakeCandidateProfileRepository repository) {
  return ProviderScope(
    overrides: [candidateProfileRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: EditProfileScreen()),
  );
}

/// A route sits beneath EditProfileScreen so its `Navigator.pop()` on save
/// has somewhere to go, instead of popping the root route.
Widget _wrapPushable(FakeCandidateProfileRepository repository) {
  return ProviderScope(
    overrides: [candidateProfileRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('EditProfileScreen', () {
    testWidgets('shows a loader while the profile is loading', (tester) async {
      await tester.pumpWidget(_wrap(FakeCandidateProfileRepository()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows a not-found message when there is no profile', (tester) async {
      await tester.pumpWidget(_wrap(FakeCandidateProfileRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Profil introuvable'), findsOneWidget);
    });

    testWidgets('shows an error message when loading fails', (tester) async {
      await tester.pumpWidget(
        _wrap(FakeCandidateProfileRepository(profileError: Exception('boom'))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
    });

    testWidgets('pre-fills the form fields from the loaded profile', (tester) async {
      const profile = Candidat(
        id: 'c1',
        userId: 'u1',
        prenom: 'Alex',
        nom: 'Nguema',
        titreProfessionnel: 'Développeur',
        ville: 'Yaoundé',
      );
      await tester.pumpWidget(_wrap(FakeCandidateProfileRepository(profile: profile)));
      await tester.pumpAndSettle();

      expect(find.text('Alex'), findsOneWidget);
      expect(find.text('Nguema'), findsOneWidget);
      expect(find.text('Développeur'), findsOneWidget);
      expect(find.text('Yaoundé'), findsOneWidget);
    });

    testWidgets('leaves fields blank when the profile has no values set', (tester) async {
      const profile = Candidat(id: 'c1', userId: 'u1');
      await tester.pumpWidget(_wrap(FakeCandidateProfileRepository(profile: profile)));
      await tester.pumpAndSettle();

      final fields = tester.widgetList<TextField>(find.byType(TextField));
      expect(fields, isNotEmpty);
      for (final field in fields) {
        expect(field.controller?.text, isEmpty);
      }
    });

    testWidgets('pre-fills email, téléphone and région from the loaded profile', (tester) async {
      const profile = Candidat(
        id: 'c1',
        userId: 'u1',
        email: 'alex@example.com',
        telephone: '+237600000000',
        region: 'Centre',
      );
      await tester.pumpWidget(_wrap(FakeCandidateProfileRepository(profile: profile)));
      await tester.pumpAndSettle();

      expect(find.text('alex@example.com'), findsOneWidget);
      expect(find.text('+237600000000'), findsOneWidget);
      expect(find.text('Centre'), findsOneWidget);
    });

    testWidgets('saving sends the edited fields, including email/téléphone/région, to the repository',
        (tester) async {
      const profile = Candidat(id: 'c1', userId: 'u1', prenom: 'Alex', nom: 'Nguema');
      final repository = FakeCandidateProfileRepository(profile: profile);
      await tester.pumpWidget(_wrapPushable(repository));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'alex@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Téléphone'), '+237600000000');
      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(repository.lastUpdatedCandidatId, 'c1');
      expect(repository.lastUpdatedChanges?['prenom'], 'Alex');
      expect(repository.lastUpdatedChanges?['email'], 'alex@example.com');
      expect(repository.lastUpdatedChanges?['telephone'], '+237600000000');
      // The save popped back to the screen with the "open" button.
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('blocks save with an invalid email and does not call the repository', (tester) async {
      const profile = Candidat(id: 'c1', userId: 'u1');
      final repository = FakeCandidateProfileRepository(profile: profile);
      await tester.pumpWidget(_wrapPushable(repository));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'not-an-email');
      await tester.enterText(find.widgetWithText(TextFormField, 'Téléphone'), '+237600000000');
      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(repository.lastUpdatedCandidatId, isNull);
      expect(find.text('Email invalide'), findsOneWidget);
    });
  });
}
