import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/core/widgets/empty_state.dart';
import 'package:mywork/models/offre.dart';
import 'package:mywork/features/jobs/application/offres_providers.dart';
import 'package:mywork/features/jobs/presentation/widgets/offre_card.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';
import 'package:mywork/features/favorites/application/favorites_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(favoritesVersionProvider);
    final favoritesRepo = ref.watch(favoritesRepositoryProvider);
    final offreIds = favoritesRepo.favoriteOfferIds();
    final offresRepo = ref.watch(offresRepositoryProvider);
    final profileAsync = ref.watch(myCandidateProfileProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favoris'),
          bottom: const TabBar(tabs: [Tab(text: 'Offres'), Tab(text: 'Entreprises')]),
        ),
        body: TabBarView(
          children: [
            if (offreIds.isEmpty)
              const EmptyState(icon: Icons.favorite_border, title: 'Aucune offre favorite')
            else
              FutureBuilder<List<Offre>>(
                future: Future.wait(offreIds.map((id) => offresRepo.getById(id))).then(
                  (list) => list.whereType<Offre>().toList(),
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const AppLoader();
                  final offers = snapshot.data!;
                  if (offers.isEmpty) {
                    return const EmptyState(icon: Icons.favorite_border, title: 'Aucune offre favorite');
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: offers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => OffreCard(
                      offre: offers[i],
                      onTap: () => context.push('/offres/${offers[i].id}'),
                    ),
                  );
                },
              ),
            profileAsync.when(
              loading: () => const AppLoader(),
              error: (e, _) => const Text('Erreur de chargement'),
              data: (profile) {
                if (profile == null) {
                  return const EmptyState(icon: Icons.business_outlined, title: 'Aucune entreprise favorite');
                }
                final companiesAsync = ref.watch(favoriteCompaniesProvider(profile.id));
                return companiesAsync.when(
                  loading: () => const AppLoader(),
                  error: (e, _) => const Text('Erreur de chargement'),
                  data: (companies) {
                    if (companies.isEmpty) {
                      return const EmptyState(icon: Icons.business_outlined, title: 'Aucune entreprise favorite');
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: companies.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final e = companies[i]['entreprise'] as Map<String, dynamic>?;
                        return ListTile(
                          leading: const Icon(Icons.business_outlined),
                          title: Text(e?['nom'] as String? ?? 'Entreprise'),
                          subtitle: Text(e?['ville'] as String? ?? ''),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
