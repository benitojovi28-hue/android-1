import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/widgets/app_card.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/features/company/application/company_providers.dart';

class CompanyDashboardScreen extends ConsumerWidget {
  const CompanyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyAsync = ref.watch(myCompanyProvider);
    final offersAsync = ref.watch(myOffersProvider);
    final applicationsAsync = ref.watch(recruiterApplicationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord')),
      body: companyAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const Text('Erreur de chargement'),
        data: (company) {
          if (company == null) return const Text('Profil entreprise introuvable');
          final offers = offersAsync.valueOrNull ?? [];
          final applications = applicationsAsync.valueOrNull ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(company.nom ?? 'Mon entreprise', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Offres actives', value: '${offers.where((o) => o.statut == 'actif').length}')),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(label: 'Candidatures', value: '${applications.length}')),
                ],
              ),
              const SizedBox(height: 12),
              _StatCard(
                label: 'Statut de vérification',
                value: company.verificationStatut ?? 'non vérifié',
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
