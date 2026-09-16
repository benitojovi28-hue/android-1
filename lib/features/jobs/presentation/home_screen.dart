import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mywork/core/widgets/app_card.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/core/widgets/section_title.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';
import 'package:mywork/features/jobs/application/offres_providers.dart';
import 'widgets/offre_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(myCandidateProfileProvider);
    final searchState = ref.watch(jobSearchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('MyWork')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(jobSearchProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              user == null
                  ? 'Bienvenue sur MyWork'
                  : 'Bonjour ${profile.valueOrNull?.prenom ?? ''}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ShortcutCard(
                    icon: Icons.search,
                    label: 'Chercher un emploi',
                    onTap: () => context.push('/offres'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ShortcutCard(
                    icon: Icons.description_outlined,
                    label: 'Mes candidatures',
                    onTap: () => context.push('/mes-candidatures'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ShortcutCard(
                    icon: Icons.storefront_outlined,
                    label: 'Services',
                    onTap: () => context.push('/services'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ShortcutCard(
                    icon: Icons.favorite_border,
                    label: 'Favoris',
                    onTap: () => context.push('/favoris'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionTitle('Offres récentes'),
            if (searchState.isLoading)
              const Padding(padding: EdgeInsets.all(32), child: AppLoader())
            else
              ...searchState.results.take(5).map(
                    (offre) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OffreCard(
                        offre: offre,
                        onTap: () => context.push('/offres/${offre.id}'),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(height: 12),
          Text(label, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}
