import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/profile_candidate/application/profile_providers.dart';
import 'package:mywork/features/profile_candidate/presentation/profile_hub_screen.dart';
import 'package:mywork/models/candidat.dart';

import '../fakes/fake_repositories.dart';

Widget _wrap(FakeCandidateProfileRepository repository) {
  return ProviderScope(
    overrides: [candidateProfileRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: ProfileHubScreen()),
  );
}

void main() {
  group('ProfileHubScreen', () {
    testWidgets('renders the candidate name, email and menu while loaded', (tester) async {
      const profile = Candidat(id: 'c1', userId: 'u1', prenom: 'Alex', nom: 'Nguema', email: 'alex@example.com');
      await tester.pumpWidget(_wrap(FakeCandidateProfileRepository(profile: profile)));
      await tester.pumpAndSettle();

      expect(find.text('Alex Nguema'), findsOneWidget);
      expect(find.text('alex@example.com'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Mes alertes'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Se déconnecter'), 200);
      expect(find.text('Se déconnecter'), findsOneWidget);
    });

    testWidgets('falls back to placeholder copy when there is no profile yet', (tester) async {
      await tester.pumpWidget(_wrap(FakeCandidateProfileRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Candidat'), findsOneWidget);
      expect(find.text('?'), findsOneWidget);
    });
  });
}
