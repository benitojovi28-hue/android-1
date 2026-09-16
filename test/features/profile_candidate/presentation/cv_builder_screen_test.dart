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

    testWidgets('pre-fills existing experiences, formations, competences and langues', (tester) async {
      const profile = Candidat(id: 'c1', userId: 'u1');
      final repository = FakeCandidateProfileRepository(profile: profile)
        ..cvNumerique = {
          'experiences': [
            {'poste': 'Développeur', 'entreprise': 'Acme', 'periode': '2021 - 2023'},
          ],
          'formations': [
            {'diplome': 'Licence Informatique', 'etablissement': 'Université de Douala', 'periode': '2018 - 2021'},
          ],
          'competences': ['Flutter', 'Dart'],
          'langues': [
            {'langue': 'Français', 'niveau': 'Natif'},
          ],
        };
      await tester.pumpWidget(_wrap(repository));
      await tester.pumpAndSettle();

      expect(find.text('Développeur'), findsOneWidget);
      expect(find.text('Acme · 2021 - 2023'), findsOneWidget);
      expect(find.text('Licence Informatique'), findsOneWidget);
      expect(find.text('Université de Douala · 2018 - 2021'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
      expect(find.text('Natif'), findsOneWidget);
      expect(find.text('Aucune entrée.'), findsNothing);
    });

    testWidgets('shows "Aucune entrée." for every section when the CV is empty', (tester) async {
      const profile = Candidat(id: 'c1', userId: 'u1');
      await tester.pumpWidget(_wrap(FakeCandidateProfileRepository(profile: profile)));
      await tester.pumpAndSettle();

      expect(find.text('Aucune entrée.'), findsNWidgets(4)); // experiences, formations, competences, langues
    });

    testWidgets('adding an experience through the dialog and saving includes it in the payload', (tester) async {
      const profile = Candidat(id: 'c1', userId: 'u1');
      final repository = FakeCandidateProfileRepository(profile: profile);
      await tester.pumpWidget(_wrap(repository));
      await tester.pumpAndSettle();

      // First IconButton is the "Ajouter" for the Expériences section.
      await tester.tap(find.byIcon(Icons.add_circle_outline).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Poste'), 'Développeur mobile');
      await tester.enterText(find.widgetWithText(TextFormField, 'Entreprise'), 'MyWork');
      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();

      expect(find.text('Développeur mobile'), findsOneWidget);

      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      final experiences = repository.cvNumerique?['experiences'] as List?;
      expect(experiences, hasLength(1));
      expect(experiences!.single['poste'], 'Développeur mobile');
      expect(experiences.single['entreprise'], 'MyWork');
    });

    testWidgets('deleting a competence chip removes it before saving', (tester) async {
      const profile = Candidat(id: 'c1', userId: 'u1');
      final repository = FakeCandidateProfileRepository(profile: profile)
        ..cvNumerique = {
          'competences': ['Flutter', 'Dart'],
        };
      await tester.pumpWidget(_wrap(repository));
      await tester.pumpAndSettle();

      final chip = tester.widget<Chip>(find.widgetWithText(Chip, 'Flutter'));
      chip.onDeleted!();
      await tester.pumpAndSettle();

      expect(find.text('Flutter'), findsNothing);
      expect(find.text('Dart'), findsOneWidget);

      await tester.ensureVisible(find.text('Enregistrer'));
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(repository.cvNumerique?['competences'], ['Dart']);
    });
  });
}
