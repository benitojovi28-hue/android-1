import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/widgets/app_card.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/features/applications/application/candidatures_providers.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';

class CandidateDashboardScreen extends ConsumerWidget {
  const CandidateDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myCandidateProfileProvider);
    final applicationsAsync = ref.watch(myApplicationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mon tableau de bord')),
      body: profileAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const Text('Erreur de chargement'),
        data: (profile) {
          final applications = applicationsAsync.valueOrNull ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatCard(label: 'Candidatures', value: '${applications.length}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Complétude profil',
                      value: '${profile?.scoreCompletude ?? 0}%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(label: 'Note moyenne', value: '${profile?.noteMoyenne ?? '—'}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(label: 'Avis reçus', value: '${profile?.nbAvis ?? 0}'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
