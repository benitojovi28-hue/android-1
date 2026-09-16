import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/widgets/app_card.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/core/widgets/empty_state.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(myReviewsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes avis')),
      body: reviewsAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const EmptyState(icon: Icons.error_outline, title: 'Erreur de chargement'),
        data: (reviews) {
          if (reviews.isEmpty) {
            return const EmptyState(icon: Icons.star_border, title: 'Aucun avis reçu');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final avis = reviews[index];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < (avis.note ?? 0) ? Icons.star : Icons.star_border,
                          size: 18,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    if (avis.commentaire != null) ...[
                      const SizedBox(height: 8),
                      Text(avis.commentaire!),
                    ],
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
