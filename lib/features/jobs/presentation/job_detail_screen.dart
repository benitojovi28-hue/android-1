import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mywork/core/utils/currency.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/core/widgets/empty_state.dart';
import 'package:mywork/features/applications/presentation/apply_sheet.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/favorites/application/favorites_providers.dart';
import 'package:go_router/go_router.dart';

import 'package:mywork/features/jobs/application/offres_providers.dart';

/// Scraped/imported offers are sometimes truncated mid-tag (e.g. an `<a
/// href="...">` cut off with no closing `>`, often ending in an ellipsis).
/// Drop that dangling fragment so the HTML parser doesn't choke on it.
String _sanitizeTruncatedHtml(String html) {
  final lastOpen = html.lastIndexOf('<');
  final lastClose = html.lastIndexOf('>');
  if (lastOpen > lastClose) {
    return html.substring(0, lastOpen).trimRight();
  }
  return html;
}

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key, required this.offreId});

  final String offreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offreAsync = ref.watch(offreDetailProvider(offreId));
    ref.watch(favoritesVersionProvider);
    final favoritesRepo = ref.watch(favoritesRepositoryProvider);
    final isFavorite = favoritesRepo.isOfferFavorite(offreId);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offre'),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () async {
              await favoritesRepo.toggleOfferFavorite(offreId);
              ref.read(favoritesVersionProvider.notifier).state++;
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              final offre = offreAsync.valueOrNull;
              if (offre != null) {
                SharePlus.instance.share(
                  ShareParams(text: '${offre.titre} — ${offre.entrepriseNom ?? 'MyWork'}'),
                );
              }
            },
          ),
        ],
      ),
      body: offreAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const EmptyState(icon: Icons.error_outline, title: 'Erreur de chargement'),
        data: (offre) {
          if (offre == null) {
            return const EmptyState(icon: Icons.search_off, title: 'Offre introuvable');
          }
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  Text(offre.titre, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  if (offre.entrepriseNom != null)
                    Text(offre.entrepriseNom!, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (offre.ville != null) Chip(label: Text(offre.ville!)),
                      if (offre.region != null) Chip(label: Text(offre.region!)),
                      if (offre.typeContrat != null) Chip(label: Text(offre.typeContrat!)),
                      if (offre.secteur != null) Chip(label: Text(offre.secteur!)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    formatSalaryRange(min: offre.salaireMin, max: offre.salaireMax, texte: offre.salaireTexte),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Text('Description', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Builder(builder: (context) {
                    final raw = offre.description?.trim() ?? '';
                    if (raw.isEmpty) {
                      return const Text('Aucune description fournie.');
                    }
                    final sanitized = _sanitizeTruncatedHtml(raw);
                    final hasVisibleText =
                        html_parser.parse(sanitized).documentElement?.text.trim().isNotEmpty ?? false;
                    if (!hasVisibleText) {
                      return const Text("Description non disponible pour cette offre.");
                    }
                    return HtmlWidget(
                      sanitized,
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      onTapUrl: (url) async {
                        final uri = Uri.tryParse(url);
                        if (uri == null) return false;
                        return launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                    );
                  }),
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                // Offers with no entrepriseId weren't posted by a registered
                // recruiter account (e.g. imported from an external feed) —
                // there's no one on MyWork to receive an in-app candidature,
                // so don't let candidates believe they successfully applied.
                child: offre.entrepriseId == null
                    ? Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Cette offre provient d'une source externe. Consultez l'annonce originale pour postuler.",
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            if (offre.sourceUrl != null) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    final uri = Uri.tryParse(offre.sourceUrl!);
                                    if (uri != null) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  icon: const Icon(Icons.open_in_new, size: 18),
                                  label: const Text("Voir l'annonce originale"),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          if (user == null) {
                            context.push('/auth');
                            return;
                          }
                          await showApplySheet(context, offreId: offre.id);
                        },
                        child: const Text('POSTULER'),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
