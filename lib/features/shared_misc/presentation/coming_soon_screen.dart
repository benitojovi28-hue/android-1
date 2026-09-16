import 'package:flutter/material.dart';

import 'package:mywork/core/widgets/empty_state.dart';

/// Generic "coming soon" screen for Tier 5 features not yet fully built
/// (fiscal docs, QR verification, tutorials, security/biometric lock).
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    this.icon = Icons.hourglass_empty,
    this.message = 'Cette fonctionnalité arrive bientôt.',
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(icon: icon, title: title, message: message),
    );
  }
}
