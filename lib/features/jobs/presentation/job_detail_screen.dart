import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:mywork/core/utils/currency.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/core/widgets/empty_state.dart';
import 'package:mywork/features/applications/presentation/apply_sheet.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/favorites/application/favorites_providers.dart';
import 'package:go_router/go_router.dart';

import 'package:mywork/features/jobs/application/offres_providers.dart';

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.offreId});

  final String offreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offreAsync = ref.watch(offreDetailProvider(offreId));
    ref.watch(favoritesVersionProvider);
    final favoritesRepo = ref.watch(favoritesRepositoryProvider);
    final isFavorite = favoritesRepo.isOfferFavorite(offreId);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offre'),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () async {
              await favoritesRepo.toggleOfferFavorite(offreId);
              ref.read(favoritesVersionProvider.notifier).state++;
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              final offre = offreAsync.valueOrNull;
              if (offre != null) {
                SharePlus.instance.share(
                  ShareParams(text: '${offre.titre} — ${offre.entrepriseNom ?? 'MyWork'}'),
                );
              }
            },
          ),
        ],
      ),
      body: offreAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const EmptyState(icon: Icons.error_outline, title: 'Erreur de chargement'),
        data: (offre) {
          if (offre == null) {
            return const EmptyState(icon: Icons.search_off, title: 'Offre introuvable');
          }
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  Text(offre.titre, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  if (offre.entrepriseNom != null)
                    Text(offre.entrepriseNom!, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (offre.ville != null) Chip(label: Text(offre.ville!)),
                      if (offre.region != null) Chip(label: Text(offre.region!)),
                      if (offre.typeContrat != null) Chip(label: Text(offre.typeContrat!)),
                      if (offre.secteur != null) Chip(label: Text(offre.secteur!)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    formatSalaryRange(min: offre.salaireMin, max: offre.salaireMax, texte: offre.salaireTexte),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Text('Description', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(offre.description ?? 'Aucune description fournie.'),
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: ElevatedButton(
                  onPressed: () async {
                    if (user == null) {
                      context.push('/auth');
                      return;
                    }
                    await showApplySheet(context, offreId: offre.id);
                  },
                  child: const Text('POSTULER'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
