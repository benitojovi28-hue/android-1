import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/widgets/app_field.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/company/application/company_providers.dart';

class CompanySignupScreen extends ConsumerStatefulWidget {
  const CompanySignupScreen({super.key});

  @override
  ConsumerState<CompanySignupScreen> createState() => _CompanySignupScreenState();
}

class _CompanySignupScreenState extends ConsumerState<CompanySignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _email = TextEditingController();
  final _telephone = TextEditingController();
  final _password = TextEditingController();

  String? _rccmDocumentName;
  Uint8List? _rccmDocumentBytes;
  bool _loading = false;
  String? _error;
  bool _done = false;

  @override
  void dispose() {
    _nom.dispose();
    _email.dispose();
    _telephone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (files.isNotEmpty) {
      final bytes = await files.first.readAsBytes();
      setState(() {
        _rccmDocumentName = files.first.name;
        _rccmDocumentBytes = bytes;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final authResponse = await ref.read(authRepositoryProvider).signUp(
            email: _email.text.trim(),
            password: _password.text,
            data: {
              'role': 'entreprise',
              'nom': _nom.text.trim(),
              'telephone': _telephone.text.trim(),
            },
          );

      if (authResponse.session == null) {
        // "Confirm email" is on for this project — no session yet, so the
        // profile-creation RPC (which requires auth.uid()) can't run. The
        // profile will self-provision on first login instead, via roleProvider.
        setState(() => _done = true);
        return;
      }

      final entrepriseId = await ref.read(roleRepositoryProvider).ensureEntrepriseProfile();
      if (entrepriseId == null) {
        setState(() => _error = "L'inscription a échoué. Réessayez.");
        return;
      }

      if (_rccmDocumentBytes != null && _rccmDocumentName != null) {
        final rccmUrl = await ref.read(companyRepositoryProvider).uploadDocument(
              folderId: entrepriseId,
              filename: _rccmDocumentName!,
              bytes: _rccmDocumentBytes!,
              contentType: 'application/octet-stream',
            );
        await ref.read(companyRepositoryProvider).updateCompany(entrepriseId, {'rccm_url': rccmUrl});
      }

      setState(() => _done = true);
    } catch (e) {
      debugPrint('[COMPANY SIGNUP ERROR] $e');
      setState(() => _error = "L'inscription a échoué. Réessayez.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inscription entreprise')),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Compte créé. Vérifiez votre email si une confirmation est requise, puis connectez-vous.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Inscription entreprise')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppField(
                controller: _nom,
                label: "Nom de l'entreprise",
                validator: (v) => (v == null || v.trim().length < 2) ? 'Nom requis' : null,
              ),
              const SizedBox(height: 16),
              AppField(
                controller: _email,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
              ),
              const SizedBox(height: 16),
              AppField(
                controller: _telephone,
                label: 'Téléphone',
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.replaceAll(RegExp(r'\D'), '').length < 8) ? 'Téléphone invalide' : null,
              ),
              const SizedBox(height: 16),
              AppField(
                controller: _password,
                label: 'Mot de passe',
                obscureText: true,
                validator: (v) => (v == null || v.length < 6) ? '6 caractères minimum' : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickDocument,
                icon: const Icon(Icons.description_outlined),
                label: Text(_rccmDocumentName ?? 'Registre de commerce (RCCM)'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Text('Créer mon compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
