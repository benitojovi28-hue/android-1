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
  });
}
