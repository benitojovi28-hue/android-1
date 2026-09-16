import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/widgets/app_field.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _prenom = TextEditingController();
  final _nom = TextEditingController();
  final _titre = TextEditingController();
  final _ville = TextEditingController();
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _prenom.dispose();
    _nom.dispose();
    _titre.dispose();
    _ville.dispose();
    super.dispose();
  }

  Future<void> _save(String candidatId) async {
    setState(() => _loading = true);
    try {
      await ref.read(candidateProfileRepositoryProvider).updateProfile(candidatId, {
        'prenom': _prenom.text.trim(),
        'nom': _nom.text.trim(),
        'titre_professionnel': _titre.text.trim(),
        'ville': _ville.text.trim(),
      });
      ref.invalidate(myCandidateProfileProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myCandidateProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier mon profil')),
      body: profileAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const Text('Erreur de chargement'),
        data: (profile) {
          if (profile == null) return const Text('Profil introuvable');
          if (!_initialized) {
            _prenom.text = profile.prenom ?? '';
            _nom.text = profile.nom ?? '';
            _titre.text = profile.titreProfessionnel ?? '';
            _ville.text = profile.ville ?? '';
            _initialized = true;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppField(controller: _prenom, label: 'Prénom'),
                const SizedBox(height: 16),
                AppField(controller: _nom, label: 'Nom'),
                const SizedBox(height: 16),
                AppField(controller: _titre, label: 'Titre professionnel'),
                const SizedBox(height: 16),
                AppField(controller: _ville, label: 'Ville'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : () => _save(profile.id),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Enregistrer'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
