import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/shared_misc/presentation/coming_soon_screen.dart';

void main() {
  group('ComingSoonScreen', () {
    testWidgets('renders the given title, icon and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ComingSoonScreen(
            title: 'Vérification QR',
            icon: Icons.qr_code,
            message: 'Bientôt disponible.',
          ),
        ),
      );

      expect(find.text('Vérification QR'), findsNWidgets(2));
      expect(find.byIcon(Icons.qr_code), findsOneWidget);
      expect(find.text('Bientôt disponible.'), findsOneWidget);
    });

    testWidgets('falls back to the default icon and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ComingSoonScreen(title: 'Documents fiscaux')),
      );

      expect(find.text('Documents fiscaux'), findsNWidgets(2));
      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
      expect(find.text('Cette fonctionnalité arrive bientôt.'), findsOneWidget);
    });
  });
}
