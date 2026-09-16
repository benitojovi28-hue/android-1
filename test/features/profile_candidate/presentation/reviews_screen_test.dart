import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/profile_candidate/application/profile_providers.dart';
import 'package:mywork/features/profile_candidate/presentation/reviews_screen.dart';
import 'package:mywork/models/avis.dart';
import 'package:mywork/models/candidat.dart';

import '../fakes/fake_repositories.dart';

const _profile = Candidat(id: 'c1', userId: 'u1', prenom: 'Alex', nom: 'Nguema');

Widget _wrap(FakeReviewsRepository reviewsRepository) {
  return ProviderScope(
    overrides: [
      candidateProfileRepositoryProvider.overrideWithValue(
        FakeCandidateProfileRepository(profile: _profile),
      ),
      reviewsRepositoryProvider.overrideWithValue(reviewsRepository),
    ],
    child: const MaterialApp(home: ReviewsScreen()),
  );
}

void main() {
  group('ReviewsScreen', () {
    testWidgets('shows the empty state when there are no reviews', (tester) async {
      await tester.pumpWidget(_wrap(FakeReviewsRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Aucun avis reçu'), findsOneWidget);
    });

    testWidgets('shows an error state when loading fails', (tester) async {
      await tester.pumpWidget(_wrap(FakeReviewsRepository(reviewsError: Exception('boom'))));
      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
    });

    testWidgets('renders filled stars matching the note and the comment', (tester) async {
      const reviews = [Avis(id: 'r1', note: 3, commentaire: 'Très bon candidat')];
      await tester.pumpWidget(_wrap(FakeReviewsRepository(reviews: reviews)));
      await tester.pumpAndSettle();

      expect(find.text('Très bon candidat'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });
  });
}
