import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/widgets/app_card.dart';
import 'package:mywork/core/widgets/app_field.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/core/widgets/empty_state.dart';
import 'package:mywork/models/alerte.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  Future<void> _createAlert(BuildContext context, WidgetRef ref, String candidatId) async {
    final controller = TextEditingController();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nouvelle alerte', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            AppField(controller: controller, label: 'Mots-clés (ex: comptable, Douala)'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Créer l\'alerte'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && controller.text.trim().isNotEmpty) {
      await ref.read(alertsRepositoryProvider).createAlert(
            AlerteCandidat(id: '', libelle: controller.text.trim(), motsCles: controller.text.trim()),
            candidatId,
          );
      ref.invalidate(myAlertsProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(myAlertsProvider);
    final profileAsync = ref.watch(myCandidateProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes alertes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final candidatId = profileAsync.valueOrNull?.id;
          if (candidatId != null) _createAlert(context, ref, candidatId);
        },
        child: const Icon(Icons.add),
      ),
      body: alertsAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const EmptyState(icon: Icons.error_outline, title: 'Erreur de chargement'),
        data: (alerts) {
          if (alerts.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'Aucune alerte',
              message: 'Créez une alerte pour être informé des nouvelles offres.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final a = alerts[index];
              return AppCard(
                child: Row(
                  children: [
                    Expanded(child: Text(a.libelle ?? a.motsCles ?? 'Alerte')),
                    Switch(
                      value: a.actif,
                      onChanged: (v) async {
                        await ref.read(alertsRepositoryProvider).setActive(a.id, v);
                        ref.invalidate(myAlertsProvider);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await ref.read(alertsRepositoryProvider).deleteAlert(a.id);
                        ref.invalidate(myAlertsProvider);
                      },
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
