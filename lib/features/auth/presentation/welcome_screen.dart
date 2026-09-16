import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mywork/core/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.brand,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(Icons.work_outline, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              Text('Bienvenue sur MyWork', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                "L'emploi et l'intérim au Cameroun, simplement.",
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push('/inscription'),
                child: const Text('Créer un compte candidat'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/entreprises/inscription'),
                child: const Text('Créer un compte entreprise'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push('/auth'),
                child: const Text('Déjà un compte ? Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
