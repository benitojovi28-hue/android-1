import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/profile_candidate/application/profile_providers.dart';
import 'package:mywork/features/profile_candidate/presentation/cv_builder_screen.dart';
import 'package:mywork/models/candidat.dart';

import '../fakes/fake_repositories.dart';

Widget _wrap(FakeCandidateProfileRepository repository) {
  return ProviderScope(
    overrides: [candidateProfileRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: CvBuilderScreen()),
  );
}

void main() {
  group('CvBuilderScreen', () {
    testWidgets('shows a not-found message when there is no profile', (tester) async {
      await tester.pumpWidget(_wrap(FakeCandidateProfileRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Profil introuvable'), findsOneWidget);
    });

    testWidgets('pre-fills the professional summary from the saved CV', (tester) async {
      const profile = Candidat(id: 'c1', userId: 'u1');
      final repository = FakeCandidateProfileRepository(profile: profile)
        ..cvNumerique = {'profil_pro': 'Développeur mobile senior'};
      await tester.pumpWidget(_wrap(repository));
      await tester.pumpAndSettle();

      expect(find.text('Développeur mobile senior'), findsOneWidget);
    });

    testWidgets('leaves the field blank when there is no saved CV yet', (tester) async {
      const profile = Candidat(id: 'c1', userId: 'u1');
      await tester.pumpWidget(_wrap(FakeCandidateProfileRepository(profile: profile)));
      await tester.pumpAndSettle();

      expect(find.text('Enregistrer'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
