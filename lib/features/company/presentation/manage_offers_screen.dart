import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mywork/core/utils/currency.dart';
import 'package:mywork/core/widgets/app_card.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/core/widgets/empty_state.dart';
import 'package:mywork/features/company/application/company_providers.dart';

class ManageOffersScreen extends ConsumerWidget {
  const ManageOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(myOffersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes offres')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/entreprise/offres/new'),
        child: const Icon(Icons.add),
      ),
      body: offersAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const EmptyState(icon: Icons.error_outline, title: 'Erreur de chargement'),
        data: (offers) {
          if (offers.isEmpty) {
            return const EmptyState(
              icon: Icons.work_outline,
              title: 'Aucune offre publiée',
              message: 'Créez votre première offre pour commencer à recruter.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myOffersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: offers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final o = offers[index];
                return AppCard(
                  onTap: () => context.push('/entreprise/offres/${o.id}/edit'),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.titre, style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: 4),
                            Text(
                              formatSalaryRange(min: o.salaireMin, max: o.salaireMax, texte: o.salaireTexte),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Chip(label: Text(o.statut ?? '—')),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
