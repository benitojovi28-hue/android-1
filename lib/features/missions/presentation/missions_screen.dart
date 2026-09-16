import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/widgets/app_card.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/core/widgets/empty_state.dart';
import 'package:mywork/features/applications/application/candidatures_providers.dart';

class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(myApplicationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes missions')),
      body: applicationsAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const EmptyState(icon: Icons.error_outline, title: 'Erreur de chargement'),
        data: (applications) {
          final missions = applications.where((c) => c.statut == 'acceptee').toList();
          if (missions.isEmpty) {
            return const EmptyState(icon: Icons.work_history_outlined, title: 'Aucune mission en cours');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: missions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final c = missions[index];
              final completed = c.employeurFinConfirmeeAt != null;
              final declared = c.employeFinDeclareeAt != null;
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.offre?.titre ?? 'Mission', style: Theme.of(context).textTheme.titleSmall),
                    if (c.offre?.entrepriseNom != null) ...[
                      const SizedBox(height: 4),
                      Text(c.offre!.entrepriseNom!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      completed
                          ? 'Mission terminée et confirmée'
                          : declared
                              ? 'Fin déclarée, en attente de confirmation'
                              : 'Mission en cours',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
