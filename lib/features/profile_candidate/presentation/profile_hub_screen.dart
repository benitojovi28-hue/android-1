import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mywork/core/widgets/app_card.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';

class ProfileHubScreen extends ConsumerWidget {
  const ProfileHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myCandidateProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(profileAsync.valueOrNull?.prenom?.characters.first ?? '?'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileAsync.valueOrNull?.displayName ?? 'Candidat',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (profileAsync.valueOrNull?.email != null)
                        Text(profileAsync.valueOrNull!.email!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _MenuTile(icon: Icons.person_outline, label: 'Modifier mon profil', onTap: () => context.push('/mon-profil/edit')),
          _MenuTile(icon: Icons.dashboard_outlined, label: 'Tableau de bord', onTap: () => context.push('/mon-tableau-de-bord')),
          _MenuTile(icon: Icons.description_outlined, label: 'Mon CV', onTap: () => context.push('/mon-cv')),
          _MenuTile(icon: Icons.folder_outlined, label: 'Mes CV téléversés', onTap: () => context.push('/mes-cv')),
          _MenuTile(icon: Icons.favorite_border, label: 'Favoris', onTap: () => context.push('/favoris')),
          _MenuTile(icon: Icons.work_history_outlined, label: 'Mes missions', onTap: () => context.push('/missions')),
          _MenuTile(icon: Icons.notifications_active_outlined, label: 'Mes alertes', onTap: () => context.push('/mes-alertes')),
          _MenuTile(icon: Icons.star_border, label: 'Mes avis', onTap: () => context.push('/mes-avis')),
          _MenuTile(icon: Icons.storefront_outlined, label: 'Mes services', onTap: () => context.push('/mes-services')),
          _MenuTile(icon: Icons.chat_bubble_outline, label: 'Messages / Support', onTap: () => context.push('/messages')),
          _MenuTile(icon: Icons.badge_outlined, label: 'Devenir recruteur', onTap: () => context.push('/devenir-recruteur')),
          _MenuTile(icon: Icons.shield_outlined, label: 'Sécurité', onTap: () => context.push('/securite')),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.logout,
            label: 'Se déconnecter',
            onTap: () => ref.read(authRepositoryProvider).signOut(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      trailing: isDestructive ? null : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
