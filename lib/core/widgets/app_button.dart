import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, ghost }

/// Wraps the theme's button styles with a loading state — port of BTN_PRIMARY
/// / BTN_SECONDARY / BTN_GHOST from the web app's mobile UI kit.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: variant == AppButtonVariant.primary
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.primary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    final pressed = loading ? null : onPressed;

    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(onPressed: pressed, child: child);
      case AppButtonVariant.secondary:
        return OutlinedButton(onPressed: pressed, child: child);
      case AppButtonVariant.ghost:
        return TextButton(onPressed: pressed, child: child);
    }
  }
}
