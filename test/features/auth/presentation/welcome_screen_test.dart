import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mywork/features/auth/presentation/welcome_screen.dart';

void main() {
  testWidgets('renders the welcome copy and the three entry buttons', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    expect(find.text('Bienvenue sur MyWork'), findsOneWidget);
    expect(find.text('Créer un compte candidat'), findsOneWidget);
    expect(find.text('Créer un compte entreprise'), findsOneWidget);
    expect(find.text('Déjà un compte ? Se connecter'), findsOneWidget);
  });
}
