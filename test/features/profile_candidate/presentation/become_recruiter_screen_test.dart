import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mywork/features/profile_candidate/presentation/become_recruiter_screen.dart';

void main() {
  group('BecomeRecruiterScreen', () {
    testWidgets('renders its static title and call-to-action', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: BecomeRecruiterScreen()));

      expect(find.text('Devenir recruteur'), findsOneWidget);
      expect(find.text('Configurer mon profil entreprise'), findsOneWidget);
    });
  });
}
