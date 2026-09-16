import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/supabase/supabase_provider.dart';
import 'package:mywork/models/offre.dart';
import 'package:mywork/features/jobs/data/offres_repository.dart';

final offresRepositoryProvider = Provider<OffresRepository>((ref) {
  return OffresRepository(ref.watch(supabaseProvider));
});

final offreDetailProvider = FutureProvider.autoDispose.family<Offre?, String>((ref, id) {
  return ref.watch(offresRepositoryProvider).getById(id);
});

class JobSearchState {
  const JobSearchState({
    this.filters = const OffresSearchFilters(),
    this.results = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  final OffresSearchFilters filters;
  final List<Offre> results;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;

  JobSearchState copyWith({
    OffresSearchFilters? filters,
    List<Offre>? results,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? error,
  }) {
    return JobSearchState(
      filters: filters ?? this.filters,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class JobSearchNotifier extends Notifier<JobSearchState> {
  @override
  JobSearchState build() {
    Future.microtask(_load);
    return const JobSearchState(isLoading: true);
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await ref.read(offresRepositoryProvider).search(state.filters);
      state = state.copyWith(
        results: results,
        isLoading: false,
        hasMore: results.length >= OffresRepository.pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> applyFilters(OffresSearchFilters filters) async {
    state = JobSearchState(filters: filters, isLoading: true);
    await _load();
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final more = await ref
          .read(offresRepositoryProvider)
          .search(state.filters, offset: state.results.length);
      state = state.copyWith(
        results: [...state.results, ...more],
        isLoadingMore: false,
        hasMore: more.length >= OffresRepository.pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e);
    }
  }

  Future<void> refresh() => _load();
}

final jobSearchProvider = NotifierProvider<JobSearchNotifier, JobSearchState>(JobSearchNotifier.new);
