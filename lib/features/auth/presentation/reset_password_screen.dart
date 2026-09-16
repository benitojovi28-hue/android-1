import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/widgets/app_field.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).resetPasswordForEmail(_email.text.trim());
      setState(() => _sent = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? const Text('Un lien de réinitialisation a été envoyé par email.')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: const Text('Envoyer le lien'),
                  ),
                ],
              ),
      ),
    );
  }
}
