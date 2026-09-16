import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/jobs/application/offres_providers.dart';
import 'package:mywork/features/jobs/data/offres_repository.dart';
import 'package:mywork/models/offre.dart';

typedef SearchHandler = Future<List<Offre>> Function(OffresSearchFilters filters, int offset);

class FakeOffresRepository implements OffresRepository {
  FakeOffresRepository({this.searchHandler, this.getByIdResult});

  SearchHandler? searchHandler;
  Offre? getByIdResult;

  int searchCallCount = 0;
  final List<int> searchOffsets = [];
  final List<OffresSearchFilters> searchFilters = [];

  @override
  Future<List<Offre>> search(OffresSearchFilters filters, {int offset = 0}) async {
    searchCallCount++;
    searchOffsets.add(offset);
    searchFilters.add(filters);
    final handler = searchHandler;
    if (handler == null) return const [];
    return handler(filters, offset);
  }

  @override
  Future<Offre?> getById(String id) async => getByIdResult;
}

List<Offre> makeOffres(int count, {int start = 0}) {
  return List.generate(count, (i) => Offre(id: 'offre-${start + i}', titre: 'Titre ${start + i}'));
}

Future<void> flushMicrotasks() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeOffresRepository fakeRepo;
  late ProviderContainer container;

  setUp(() {
    fakeRepo = FakeOffresRepository();
    container = ProviderContainer(
      overrides: [offresRepositoryProvider.overrideWithValue(fakeRepo)],
    );
    addTearDown(container.dispose);
  });

  group('JobSearchNotifier.build', () {
    test('starts in a loading state with no results', () {
      final state = container.read(jobSearchProvider);
      expect(state.isLoading, isTrue);
      expect(state.results, isEmpty);
    });

    test('auto-loads results via a microtask', () async {
      fakeRepo.searchHandler = (filters, offset) async => makeOffres(3);

      container.read(jobSearchProvider);
      await flushMicrotasks();

      final state = container.read(jobSearchProvider);
      expect(state.isLoading, isFalse);
      expect(state.results, hasLength(3));
      expect(fakeRepo.searchCallCount, 1);
      expect(fakeRepo.searchOffsets.single, 0);
    });

    test('hasMore is true when a full page is returned', () async {
      fakeRepo.searchHandler = (filters, offset) async => makeOffres(OffresRepository.pageSize);

      container.read(jobSearchProvider);
      await flushMicrotasks();

      expect(container.read(jobSearchProvider).hasMore, isTrue);
    });

    test('hasMore is false when fewer than a full page is returned', () async {
      fakeRepo.searchHandler = (filters, offset) async => makeOffres(OffresRepository.pageSize - 1);

      container.read(jobSearchProvider);
      await flushMicrotasks();

      expect(container.read(jobSearchProvider).hasMore, isFalse);
    });

    test('a load failure sets error and clears loading without touching results', () async {
      fakeRepo.searchHandler = (filters, offset) async => throw StateError('boom');

      container.read(jobSearchProvider);
      await flushMicrotasks();

      final state = container.read(jobSearchProvider);
      expect(state.isLoading, isFalse);
      expect(state.error, isA<StateError>());
      expect(state.results, isEmpty);
    });
  });

  group('JobSearchNotifier.applyFilters', () {
    test('resets state and reloads with the new filters', () async {
      fakeRepo.searchHandler = (filters, offset) async => makeOffres(2);
      container.read(jobSearchProvider);
      await flushMicrotasks();

      const newFilters = OffresSearchFilters(query: 'flutter', region: 'Littoral');
      fakeRepo.searchHandler = (filters, offset) async => makeOffres(1, start: 100);
      final future = container.read(jobSearchProvider.notifier).applyFilters(newFilters);
      await future;

      final state = container.read(jobSearchProvider);
      expect(state.filters, newFilters);
      expect(state.results, hasLength(1));
      expect(state.results.single.id, 'offre-100');
      expect(fakeRepo.searchFilters.last, newFilters);
    });

    test('preserves an in-flight error only until the reload finishes', () async {
      fakeRepo.searchHandler = (filters, offset) async => throw StateError('boom');
      container.read(jobSearchProvider);
      await flushMicrotasks();
      expect(container.read(jobSearchProvider).error, isNotNull);

      fakeRepo.searchHandler = (filters, offset) async => makeOffres(2);
      await container.read(jobSearchProvider.notifier).applyFilters(const OffresSearchFilters());

      expect(container.read(jobSearchProvider).error, isNull);
    });
  });

  group('JobSearchNotifier.loadMore', () {
    test('appends the next page to existing results', () async {
      fakeRepo.searchHandler = (filters, offset) async => makeOffres(OffresRepository.pageSize);
      container.read(jobSearchProvider);
      await flushMicrotasks();

      fakeRepo.searchHandler = (filters, offset) async => makeOffres(5, start: 1000);
      await container.read(jobSearchProvider.notifier).loadMore();

      final state = container.read(jobSearchProvider);
      expect(state.results, hasLength(OffresRepository.pageSize + 5));
      expect(fakeRepo.searchOffsets.last, OffresRepository.pageSize);
      expect(state.hasMore, isFalse);
      expect(state.isLoadingMore, isFalse);
    });

    test('is a no-op when hasMore is false', () async {
      fakeRepo.searchHandler = (filters, offset) async => makeOffres(2);
      container.read(jobSearchProvider);
      await flushMicrotasks();
      expect(container.read(jobSearchProvider).hasMore, isFalse);

      final callsBefore = fakeRepo.searchCallCount;
      await container.read(jobSearchProvider.notifier).loadMore();

      expect(fakeRepo.searchCallCount, callsBefore);
    });

    test('is a no-op when a load is already in flight', () async {
      fakeRepo.searchHandler = (filters, offset) async => makeOffres(OffresRepository.pageSize);
      container.read(jobSearchProvider);
      await flushMicrotasks();

      final gate = Completer<void>();
      fakeRepo.searchHandler = (filters, offset) async {
        await gate.future;
        return makeOffres(3, start: 500);
      };

      final first = container.read(jobSearchProvider.notifier).loadMore();
      // The first call is now in flight (isLoadingMore == true); a second
      // concurrent call must bail out immediately without hitting the repo.
      expect(container.read(jobSearchProvider).isLoadingMore, isTrue);
      final callsBeforeSecond = fakeRepo.searchCallCount;
      await container.read(jobSearchProvider.notifier).loadMore();
      expect(fakeRepo.searchCallCount, callsBeforeSecond);

      gate.complete();
      await first;
      expect(container.read(jobSearchProvider).results, hasLength(OffresRepository.pageSize + 3));
    });

    test('records the error and preserves existing results on failure', () async {
      fakeRepo.searchHandler = (filters, offset) async => makeOffres(OffresRepository.pageSize);
      container.read(jobSearchProvider);
      await flushMicrotasks();
      final resultsBefore = container.read(jobSearchProvider).results;

      fakeRepo.searchHandler = (filters, offset) async => throw StateError('load more failed');
      await container.read(jobSearchProvider.notifier).loadMore();

      final state = container.read(jobSearchProvider);
      expect(state.error, isA<StateError>());
      expect(state.results, resultsBefore);
      expect(state.isLoadingMore, isFalse);
    });
  });

  group('JobSearchNotifier.refresh', () {
    test('reloads and replaces results wholesale', () async {
      fakeRepo.searchHandler = (filters, offset) async => makeOffres(2);
      container.read(jobSearchProvider);
      await flushMicrotasks();

      fakeRepo.searchHandler = (filters, offset) async => makeOffres(4, start: 200);
      await container.read(jobSearchProvider.notifier).refresh();

      final state = container.read(jobSearchProvider);
      expect(state.results, hasLength(4));
      expect(state.results.first.id, 'offre-200');
    });
  });
}
