import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/profile_candidate/application/profile_providers.dart';
import 'package:mywork/models/alerte.dart';
import 'package:mywork/models/avis.dart';
import 'package:mywork/models/candidat.dart';

import '../fakes/fake_repositories.dart';

const _profile = Candidat(id: 'c1', userId: 'u1', prenom: 'Alex', nom: 'Nguema');

void main() {
  group('myCandidateProfileProvider', () {
    test('surfaces the profile returned by the repository', () async {
      final container = ProviderContainer(
        overrides: [
          candidateProfileRepositoryProvider.overrideWithValue(
            FakeCandidateProfileRepository(profile: _profile),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(myCandidateProfileProvider.future);

      expect(result, _profile);
    });

    test('surfaces a null profile', () async {
      final container = ProviderContainer(
        overrides: [
          candidateProfileRepositoryProvider.overrideWithValue(
            FakeCandidateProfileRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(myCandidateProfileProvider.future);

      expect(result, isNull);
    });

    test('surfaces repository errors', () async {
      final container = ProviderContainer(
        overrides: [
          candidateProfileRepositoryProvider.overrideWithValue(
            FakeCandidateProfileRepository(profileError: Exception('boom')),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(myCandidateProfileProvider.future),
        throwsA(isException),
      );
    });
  });

  group('myAlertsProvider', () {
    test('returns an empty list when there is no candidate profile', () async {
      final container = ProviderContainer(
        overrides: [
          candidateProfileRepositoryProvider.overrideWithValue(FakeCandidateProfileRepository()),
          alertsRepositoryProvider.overrideWithValue(
            FakeAlertsRepository(alerts: const [AlerteCandidat(id: 'a1', libelle: 'Should not show')]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(myAlertsProvider.future);

      expect(result, isEmpty);
    });

    test('returns the alerts scoped to the current candidate', () async {
      const alerts = [
        AlerteCandidat(id: 'a1', libelle: 'Alerte Dev'),
        AlerteCandidat(id: 'a2', libelle: 'Alerte Compta'),
      ];
      final container = ProviderContainer(
        overrides: [
          candidateProfileRepositoryProvider.overrideWithValue(
            FakeCandidateProfileRepository(profile: _profile),
          ),
          alertsRepositoryProvider.overrideWithValue(FakeAlertsRepository(alerts: alerts)),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(myAlertsProvider.future);

      expect(result, alerts);
    });

    test('surfaces alert repository errors', () async {
      final container = ProviderContainer(
        overrides: [
          candidateProfileRepositoryProvider.overrideWithValue(
            FakeCandidateProfileRepository(profile: _profile),
          ),
          alertsRepositoryProvider.overrideWithValue(
            FakeAlertsRepository(alertsError: Exception('boom')),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(myAlertsProvider.future),
        throwsA(isException),
      );
    });
  });

  group('myReviewsProvider', () {
    test('returns an empty list when there is no candidate profile', () async {
      final container = ProviderContainer(
        overrides: [
          candidateProfileRepositoryProvider.overrideWithValue(FakeCandidateProfileRepository()),
          reviewsRepositoryProvider.overrideWithValue(
            FakeReviewsRepository(reviews: const [Avis(id: 'r1', note: 5)]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(myReviewsProvider.future);

      expect(result, isEmpty);
    });

    test('returns the reviews for the current candidate', () async {
      const reviews = [Avis(id: 'r1', note: 5), Avis(id: 'r2', note: 3)];
      final container = ProviderContainer(
        overrides: [
          candidateProfileRepositoryProvider.overrideWithValue(
            FakeCandidateProfileRepository(profile: _profile),
          ),
          reviewsRepositoryProvider.overrideWithValue(FakeReviewsRepository(reviews: reviews)),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(myReviewsProvider.future);

      expect(result, reviews);
    });

    test('surfaces review repository errors', () async {
      final container = ProviderContainer(
        overrides: [
          candidateProfileRepositoryProvider.overrideWithValue(
            FakeCandidateProfileRepository(profile: _profile),
          ),
          reviewsRepositoryProvider.overrideWithValue(
            FakeReviewsRepository(reviewsError: Exception('boom')),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(myReviewsProvider.future),
        throwsA(isException),
      );
    });
  });
}
