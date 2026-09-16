import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mywork/core/widgets/app_card.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/core/widgets/empty_state.dart';
import 'package:mywork/features/company/application/company_providers.dart';
import 'package:mywork/features/applications/application/candidatures_providers.dart';

const _statuts = ['envoyee', 'vue', 'entretien', 'acceptee', 'refusee'];

class RecruiterApplicationsScreen extends ConsumerWidget {
  const RecruiterApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(recruiterApplicationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Candidatures')),
      body: applicationsAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const EmptyState(icon: Icons.error_outline, title: 'Erreur de chargement'),
        data: (applications) {
          if (applications.isEmpty) {
            return const EmptyState(icon: Icons.inbox_outlined, title: 'Aucune candidature reçue');
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(recruiterApplicationsProvider),
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
                      Text(c.candidatNom ?? 'Candidat', style: Theme.of(context).textTheme.titleSmall),
                      if (c.offre?.titre != null) ...[
                        const SizedBox(height: 4),
                        Text(c.offre!.titre, style: Theme.of(context).textTheme.bodySmall),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _statuts.contains(c.statut) ? c.statut : null,
                              decoration: const InputDecoration(labelText: 'Statut', isDense: true),
                              items: _statuts.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (v) async {
                                if (v == null) return;
                                await ref.read(candidaturesRepositoryProvider).changeStatus(c.id, v);
                                ref.invalidate(recruiterApplicationsProvider);
                              },
                            ),
                          ),
                          if (c.candidatTelephone != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.call_outlined),
                              onPressed: () => launchUrl(Uri.parse('tel:${c.candidatTelephone}')),
                            ),
                          ],
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
