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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
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
              decoration: const InputDecoration(
                hintText: 'Rechercher un poste, un métier...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (q) {
                ref.read(jobSearchProvider.notifier).applyFilters(
                      state.filters.copyWith(query: q),
                    );
              },
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
