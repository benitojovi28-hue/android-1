import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/widgets/app_field.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/company/application/company_providers.dart';

class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
  final _nom = TextEditingController();
  final _secteur = TextEditingController();
  final _ville = TextEditingController();
  final _description = TextEditingController();
  bool _loading = false;
  bool _initialized = false;

  Future<void> _save(String entrepriseId) async {
    setState(() => _loading = true);
    try {
      await ref.read(companyRepositoryProvider).updateCompany(entrepriseId, {
        'nom': _nom.text.trim(),
        'secteur': _secteur.text.trim(),
        'ville': _ville.text.trim(),
        'description': _description.text.trim(),
      });
      ref.invalidate(myCompanyProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour.')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyAsync = ref.watch(myCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon entreprise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: companyAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const Text('Erreur de chargement'),
        data: (company) {
          if (company == null) return const Text('Profil entreprise introuvable');
          if (!_initialized) {
            _nom.text = company.nom ?? '';
            _secteur.text = company.secteur ?? '';
            _ville.text = company.ville ?? '';
            _description.text = company.description ?? '';
            _initialized = true;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Chip(label: Text('Vérification : ${company.verificationStatut ?? "non vérifié"}')),
                const SizedBox(height: 16),
                AppField(controller: _nom, label: 'Nom'),
                const SizedBox(height: 16),
                AppField(controller: _secteur, label: "Secteur d'activité"),
                const SizedBox(height: 16),
                AppField(controller: _ville, label: 'Ville'),
                const SizedBox(height: 16),
                AppField(controller: _description, label: 'Description', maxLines: 4),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : () => _save(company.id),
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
