import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/utils/time_ago.dart';
import 'package:mywork/core/widgets/app_card.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/core/widgets/empty_state.dart';
import 'package:mywork/features/applications/application/candidatures_providers.dart';

class MyApplicationsScreen extends ConsumerWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(myApplicationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes candidatures')),
      body: applicationsAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const EmptyState(icon: Icons.error_outline, title: 'Erreur de chargement'),
        data: (applications) {
          if (applications.isEmpty) {
            return const EmptyState(
              icon: Icons.description_outlined,
              title: 'Aucune candidature',
              message: "Vos candidatures apparaîtront ici une fois envoyées.",
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myApplicationsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final c = applications[index];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.offre?.titre ?? 'Offre', style: Theme.of(context).textTheme.titleSmall),
                      if (c.offre?.entrepriseNom != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          c.offre!.entrepriseNom!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatusChip(statut: c.statut),
                          Text(timeAgo(c.createdAt), style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.statut});

  final String statut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        statut,
        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}
