import 'package:flutter/material.dart';

/// Small pill used for filters/tags — port of `Chip` in the web app's mobile UI kit.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    final bg = selected ? theme.colorScheme.primary : theme.chipTheme.backgroundColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: theme.textTheme.labelMedium?.copyWith(color: fg)),
      ),
    );
  }
}
