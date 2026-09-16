import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/utils/currency.dart';
import 'package:mywork/core/widgets/app_card.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/core/widgets/empty_state.dart';
import 'package:mywork/features/services_marketplace/application/services_providers.dart';

class ServicesBrowseScreen extends ConsumerWidget {
  const ServicesBrowseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesBrowseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: servicesAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const EmptyState(icon: Icons.error_outline, title: 'Erreur de chargement'),
        data: (services) {
          if (services.isEmpty) {
            return const EmptyState(icon: Icons.storefront_outlined, title: 'Aucun service disponible');
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(servicesBrowseProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final s = services[index];
                return AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.titre, style: Theme.of(context).textTheme.titleSmall),
                            if (s.categorie != null) ...[
                              const SizedBox(height: 4),
                              Text(s.categorie!, style: Theme.of(context).textTheme.bodySmall),
                            ],
                            if (s.localisation != null) ...[
                              const SizedBox(height: 4),
                              Text(s.localisation!, style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ],
                        ),
                      ),
                      if (s.prix != null) Text(formatFcfa(s.prix)),
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
