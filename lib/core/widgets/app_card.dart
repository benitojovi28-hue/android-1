import 'package:flutter/material.dart';

import 'package:mywork/core/theme/app_radii.dart';
import 'package:mywork/core/theme/app_shadows.dart';

/// Flat, rounded card used across list/browse screens — port of AppCard from
/// the web app's mobile UI kit (src/components/app/ui.tsx).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.withShadow = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool withShadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.6)),
        boxShadow: withShadow ? AppShadows.flat : null,
      ),
      child: child,
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: card,
    );
  }
}
