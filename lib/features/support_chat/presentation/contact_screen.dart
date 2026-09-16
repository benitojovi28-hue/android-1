import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/supabase/supabase_provider.dart';
import 'package:mywork/core/widgets/app_field.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';

/// Contact/support ticket form — writes to `demandes_contact`, the table
/// backing the web app's public /contact route (separate from the
/// AI-assisted support_conversations/support_messages chat).
class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _sujet = TextEditingController();
  final _message = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final user = ref.read(currentUserProvider);
      await ref.read(supabaseProvider).from('demandes_contact').insert({
        if (user != null) 'user_id': user.id,
        'sujet': _sujet.text.trim(),
        'message': _message.text.trim(),
      });
      setState(() => _sent = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? const Text('Votre message a été envoyé. Nous vous répondrons rapidement.')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppField(controller: _sujet, label: 'Sujet'),
                  const SizedBox(height: 16),
                  AppField(controller: _message, label: 'Message', maxLines: 5),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text('Envoyer'),
                  ),
                ],
              ),
      ),
    );
  }
}
