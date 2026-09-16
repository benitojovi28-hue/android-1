import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/applications/application/candidatures_providers.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';
import 'package:mywork/features/profile_candidate/presentation/dashboard_screen.dart';
import 'package:mywork/models/candidat.dart';
import 'package:mywork/models/candidature.dart';

import '../../missions/fakes/fake_candidatures_repository.dart';
import '../fakes/fake_repositories.dart';

Widget _wrap({
  required FakeCandidateProfileRepository profileRepository,
  required FakeCandidaturesRepository candidaturesRepository,
}) {
  return ProviderScope(
    overrides: [
      candidateProfileRepositoryProvider.overrideWithValue(profileRepository),
      candidaturesRepositoryProvider.overrideWithValue(candidaturesRepository),
    ],
    child: const MaterialApp(home: CandidateDashboardScreen()),
  );
}

void main() {
  group('CandidateDashboardScreen', () {
    testWidgets('renders stats from the profile and applications', (tester) async {
      const profile = Candidat(
        id: 'c1',
        userId: 'u1',
        scoreCompletude: 80,
        noteMoyenne: 4.5,
        nbAvis: 10,
      );
      final applications = [
        Candidature(id: 'a1', createdAt: DateTime(2026, 1, 1), statut: 'envoyee'),
        Candidature(id: 'a2', createdAt: DateTime(2026, 1, 2), statut: 'acceptee'),
      ];
      await tester.pumpWidget(
        _wrap(
          profileRepository: FakeCandidateProfileRepository(profile: profile),
          candidaturesRepository: FakeCandidaturesRepository(applications: applications),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('falls back to defaults when there is no profile yet', (tester) async {
      await tester.pumpWidget(
        _wrap(
          profileRepository: FakeCandidateProfileRepository(),
          candidaturesRepository: FakeCandidaturesRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0'), findsWidgets);
      expect(find.text('0%'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
    });
  });
}
