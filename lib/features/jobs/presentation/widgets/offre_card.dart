import 'package:flutter/material.dart';

import 'package:mywork/core/utils/currency.dart';
import 'package:mywork/core/utils/time_ago.dart';
import 'package:mywork/core/widgets/app_card.dart';
import 'package:mywork/models/offre.dart';

class OffreCard extends StatelessWidget {
  const OffreCard({super.key, required this.offre, this.onTap, this.trailing});

  final Offre offre;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(offre.titre, style: theme.textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                if (offre.entrepriseNom != null)
                  Text(
                    offre.entrepriseNom!,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (offre.ville != null) _Tag(icon: Icons.location_on_outlined, label: offre.ville!),
                    if (offre.typeContrat != null) _Tag(icon: Icons.work_outline, label: offre.typeContrat!),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  formatSalaryRange(min: offre.salaireMin, max: offre.salaireMax, texte: offre.salaireTexte),
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
                ),
                if (offre.datePublication != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    timeAgo(offre.datePublication!),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
