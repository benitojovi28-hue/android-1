import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BecomeRecruiterScreen extends StatelessWidget {
  const BecomeRecruiterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devenir recruteur')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Créez un profil entreprise pour publier des offres et recruter sur MyWork.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/entreprises/inscription'),
              child: const Text('Configurer mon profil entreprise'),
            ),
          ],
        ),
      ),
    );
  }
}
