import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/core/widgets/empty_state.dart';
import 'package:mywork/features/jobs/application/offres_providers.dart';
import 'widgets/filters_sheet.dart';
import 'widgets/offre_card.dart';

class JobSearchScreen extends ConsumerStatefulWidget {
  const JobSearchScreen({super.key});

  @override
  ConsumerState<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends ConsumerState<JobSearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 300) {
      ref.read(jobSearchProvider.notifier).loadMore();
    }
  }

  void _search(String q) {
    _debounce?.cancel();
    final filters = ref.read(jobSearchProvider).filters;
    ref.read(jobSearchProvider.notifier).applyFilters(filters.copyWith(query: q));
  }

  void _onQueryChanged(String q) {
    setState(() {}); // toggle the clear button's visibility
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(q));
  }

  void _clearQuery() {
    _searchController.clear();
    _search('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offres'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () async {
              final filters = await showJobFiltersSheet(context, state.filters);
              if (filters != null) {
                await ref.read(jobSearchProvider.notifier).applyFilters(filters);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un poste, un métier...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearQuery,
                      ),
              ),
              onChanged: _onQueryChanged,
              onSubmitted: _search,
            ),
          ),
          Expanded(
            child: state.isLoading
                ? const AppLoader()
                : state.results.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        title: 'Aucune offre trouvée',
                        message: 'Essayez de modifier vos filtres de recherche.',
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(jobSearchProvider.notifier).refresh(),
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: state.results.length + (state.hasMore ? 1 : 0),
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index >= state.results.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: AppLoader(size: 22),
                              );
                            }
                            final offre = state.results[index];
                            return OffreCard(
                              offre: offre,
                              onTap: () => context.push('/offres/${offre.id}'),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
