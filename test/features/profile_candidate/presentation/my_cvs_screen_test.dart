import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/applications/application/candidatures_providers.dart';
import 'package:mywork/features/profile_candidate/presentation/my_cvs_screen.dart';
import 'package:mywork/models/candidat_cv.dart';

import '../../missions/fakes/fake_candidatures_repository.dart';

Widget _wrap(FakeCandidaturesRepository repository) {
  return ProviderScope(
    overrides: [candidaturesRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: MyCvsScreen()),
  );
}

void main() {
  group('MyCvsScreen', () {
    testWidgets('shows a loader while CVs are loading', (tester) async {
      await tester.pumpWidget(_wrap(FakeCandidaturesRepository()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows the empty state when there are no CVs', (tester) async {
      await tester.pumpWidget(_wrap(FakeCandidaturesRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Aucun CV téléversé'), findsOneWidget);
    });

    testWidgets('shows an error state when loading fails', (tester) async {
      await tester.pumpWidget(
        _wrap(FakeCandidaturesRepository(cvsError: Exception('boom'))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
    });

    testWidgets('renders each uploaded CV by name', (tester) async {
      const cvs = [
        CandidatCvFile(id: 'cv1', nom: 'CV Alex.pdf', fichierUrl: 'path/1'),
        CandidatCvFile(id: 'cv2', nom: 'CV Alex - v2.pdf', fichierUrl: 'path/2'),
      ];
      await tester.pumpWidget(_wrap(FakeCandidaturesRepository(cvs: cvs)));
      await tester.pumpAndSettle();

      expect(find.text('CV Alex.pdf'), findsOneWidget);
      expect(find.text('CV Alex - v2.pdf'), findsOneWidget);
    });

    testWidgets('tapping delete calls deleteCv on the repository', (tester) async {
      const cvs = [CandidatCvFile(id: 'cv1', nom: 'CV Alex.pdf', fichierUrl: 'path/1')];
      final repository = FakeCandidaturesRepository(cvs: cvs);
      await tester.pumpWidget(_wrap(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(repository.deletedCvIds, ['cv1']);
    });
  });
}
