import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/support_chat/presentation/contact_screen.dart';

void main() {
  group('ContactScreen', () {
    testWidgets('renders the contact form with subject, message and send button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ContactScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Contact'), findsOneWidget);
      expect(find.text('Sujet'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Envoyer'), findsOneWidget);
    });
  });
}
