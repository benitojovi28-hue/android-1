import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mywork/features/auth/application/auth_providers.dart';

/// Shown when the account has no candidats/entreprises row yet (role ==
/// unknown) — lets the user finish setting up the right kind of profile.
class ChooseSpaceScreen extends ConsumerWidget {
  const ChooseSpaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir un espace')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Votre compte existe mais aucun profil n\'est encore configuré.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/inscription'),
              child: const Text('Configurer un profil candidat'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push('/entreprises/inscription'),
              child: const Text('Configurer un profil entreprise'),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              child: const Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}
