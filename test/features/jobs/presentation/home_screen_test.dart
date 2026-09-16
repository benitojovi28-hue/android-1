import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/jobs/application/offres_providers.dart';
import 'package:mywork/features/jobs/data/offres_repository.dart';
import 'package:mywork/features/jobs/presentation/home_screen.dart';
import 'package:mywork/features/jobs/presentation/widgets/offre_card.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';
import 'package:mywork/models/offre.dart';

typedef SearchHandler = Future<List<Offre>> Function(OffresSearchFilters filters, int offset);

class FakeOffresRepository implements OffresRepository {
  FakeOffresRepository(this.searchHandler);

  final SearchHandler searchHandler;

  @override
  Future<List<Offre>> search(OffresSearchFilters filters, {int offset = 0}) =>
      searchHandler(filters, offset);

  @override
  Future<Offre?> getById(String id) async => null;
}

List<Offre> makeOffres(int count) =>
    List.generate(count, (i) => Offre(id: 'offre-$i', titre: 'Titre $i'));

void main() {
  List<Override> baseOverrides(FakeOffresRepository repo) => [
        offresRepositoryProvider.overrideWithValue(repo),
        currentUserProvider.overrideWithValue(null),
        myCandidateProfileProvider.overrideWith((ref) => Future.value(null)),
      ];

  testWidgets('shows a loading indicator while jobs are loading', (tester) async {
    final gate = Completer<List<Offre>>();
    final repo = FakeOffresRepository((filters, offset) => gate.future);

    await tester.pumpWidget(
      ProviderScope(
        overrides: baseOverrides(repo),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(OffreCard), findsNothing);
  });

  testWidgets('shows at most the first 5 recent offers', (tester) async {
    addTearDown(() => tester.view.resetPhysicalSize());
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;

    final repo = FakeOffresRepository((filters, offset) async => makeOffres(8));

    await tester.pumpWidget(
      ProviderScope(
        overrides: baseOverrides(repo),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(OffreCard), findsNWidgets(5));
    expect(find.text('Titre 0'), findsOneWidget);
    expect(find.text('Titre 4'), findsOneWidget);
    expect(find.text('Titre 5'), findsNothing);
  });

  testWidgets('shows the guest greeting when there is no signed-in user', (tester) async {
    final repo = FakeOffresRepository((filters, offset) async => const []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: baseOverrides(repo),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Bienvenue sur MyWork'), findsOneWidget);
  });
}
