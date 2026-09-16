import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/widgets/app_card.dart';
import 'package:mywork/core/widgets/app_field.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/core/widgets/empty_state.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/models/service.dart';
import 'package:mywork/features/services_marketplace/application/services_providers.dart';

final _myServicesProvider = FutureProvider.autoDispose<List<ServiceListing>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  return ref.watch(servicesRepositoryProvider).myServices(user.id);
});

class MyServicesScreen extends ConsumerWidget {
  const MyServicesScreen({super.key});

  Future<void> _createService(BuildContext context, WidgetRef ref) async {
    final titre = TextEditingController();
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
            Text('Nouveau service', style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 16),
            AppField(controller: titre, label: 'Titre du service'),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Publier')),
          ],
        ),
      ),
    );

    final user = ref.read(currentUserProvider);
    if (saved == true && titre.text.trim().isNotEmpty && user != null) {
      await ref.read(servicesRepositoryProvider).createService({
        'user_id': user.id,
        'user_role': 'candidat',
        'titre': titre.text.trim(),
        'is_active': true,
      });
      ref.invalidate(_myServicesProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(_myServicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes services')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createService(context, ref),
        child: const Icon(Icons.add),
      ),
      body: servicesAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const EmptyState(icon: Icons.error_outline, title: 'Erreur de chargement'),
        data: (services) {
          if (services.isEmpty) {
            return const EmptyState(icon: Icons.storefront_outlined, title: 'Aucun service publié');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final s = services[index];
              return AppCard(
                child: Row(
                  children: [
                    Expanded(child: Text(s.titre)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await ref.read(servicesRepositoryProvider).deleteService(s.id);
                        ref.invalidate(_myServicesProvider);
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
