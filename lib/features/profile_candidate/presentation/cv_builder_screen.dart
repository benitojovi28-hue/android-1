import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/widgets/app_field.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';

/// Structured "CV MyWork" builder (candidat_cv jsonb) — v1 covers the
/// core professional-summary fields; full experiences/formations editors
/// can be layered on later.
class CvBuilderScreen extends ConsumerStatefulWidget {
  const CvBuilderScreen({super.key});

  @override
  ConsumerState<CvBuilderScreen> createState() => _CvBuilderScreenState();
}

class _CvBuilderScreenState extends ConsumerState<CvBuilderScreen> {
  final _profilPro = TextEditingController();
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _profilPro.dispose();
    super.dispose();
  }

  Future<void> _save(String candidatId) async {
    setState(() => _loading = true);
    try {
      await ref.read(candidateProfileRepositoryProvider).saveCvNumerique(candidatId, {
        'profil_pro': _profilPro.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CV MyWork enregistré.')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myCandidateProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mon CV MyWork')),
      body: profileAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const Text('Erreur de chargement'),
        data: (profile) {
          if (profile == null) return const Text('Profil introuvable');
          return FutureBuilder<Map<String, dynamic>?>(
            future: ref.read(candidateProfileRepositoryProvider).myCvNumerique(profile.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const AppLoader();
              if (!_initialized) {
                _profilPro.text = snapshot.data?['profil_pro'] as String? ?? '';
                _initialized = true;
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ce CV en ligne peut être utilisé directement pour postuler, sans fichier à télécharger.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    AppField(controller: _profilPro, label: 'Profil professionnel', maxLines: 6),
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
          );
        },
      ),
    );
  }
}
