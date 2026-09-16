import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mywork/core/utils/region_cameroun.dart';
import 'package:mywork/core/widgets/app_field.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/features/jobs/application/offres_providers.dart';
import 'package:mywork/features/company/application/company_providers.dart';

class EditOfferScreen extends ConsumerStatefulWidget {
  const EditOfferScreen({super.key, this.offreId});

  /// null means "create new offer".
  final String? offreId;

  @override
  ConsumerState<EditOfferScreen> createState() => _EditOfferScreenState();
}

class _EditOfferScreenState extends ConsumerState<EditOfferScreen> {
  final _titre = TextEditingController();
  final _description = TextEditingController();
  final _ville = TextEditingController();
  final _salaireMin = TextEditingController();
  final _salaireMax = TextEditingController();
  String? _region;
  String? _typeContrat;
  bool _loading = false;
  bool _initialized = false;

  static const _contrats = ['CDI', 'CDD', 'Stage', 'Freelance', 'Intérim'];

  bool get isEditing => widget.offreId != null;

  @override
  void dispose() {
    _titre.dispose();
    _description.dispose();
    _ville.dispose();
    _salaireMin.dispose();
    _salaireMax.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final company = await ref.read(myCompanyProvider.future);
      if (company == null) return;

      final data = {
        'titre': _titre.text.trim(),
        'description': _description.text.trim(),
        'ville': _ville.text.trim().isEmpty ? null : _ville.text.trim(),
        'region': _region,
        'type_contrat': _typeContrat,
        'salaire_min': num.tryParse(_salaireMin.text.trim()),
        'salaire_max': num.tryParse(_salaireMax.text.trim()),
        'entreprise_id': company.id,
        'entreprise_nom': company.nom,
        'statut': 'actif',
      };

      if (isEditing) {
        await ref.read(companyRepositoryProvider).updateOffer(widget.offreId!, data);
      } else {
        await ref.read(companyRepositoryProvider).createOffer(data);
      }
      ref.invalidate(myOffersProvider);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _archive() async {
    if (widget.offreId == null) return;
    await ref.read(companyRepositoryProvider).archiveOffer(widget.offreId!);
    ref.invalidate(myOffersProvider);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final offreAsync = isEditing ? ref.watch(offreDetailProvider(widget.offreId!)) : null;

    Widget form() {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppField(controller: _titre, label: 'Titre du poste'),
            const SizedBox(height: 16),
            AppField(controller: _description, label: 'Description', maxLines: 5),
            const SizedBox(height: 16),
            AppField(controller: _ville, label: 'Ville'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _region,
              decoration: const InputDecoration(labelText: 'Région'),
              items: RegionCameroun.values
                  .map((r) => DropdownMenuItem(value: r.dbValue, child: Text(r.dbValue)))
                  .toList(),
              onChanged: (v) => setState(() => _region = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _typeContrat,
              decoration: const InputDecoration(labelText: 'Type de contrat'),
              items: _contrats.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _typeContrat = v),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppField(
                    controller: _salaireMin,
                    label: 'Salaire min (FCFA)',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppField(
                    controller: _salaireMax,
                    label: 'Salaire max (FCFA)',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(isEditing ? 'Enregistrer' : "Publier l'offre"),
            ),
            if (isEditing) ...[
              const SizedBox(height: 8),
              OutlinedButton(onPressed: _archive, child: const Text('Archiver cette offre')),
            ],
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Modifier l'offre" : 'Nouvelle offre')),
      body: isEditing
          ? offreAsync!.when(
              loading: () => const AppLoader(),
              error: (e, _) => const Text('Erreur de chargement'),
              data: (offre) {
                if (offre != null && !_initialized) {
                  _titre.text = offre.titre;
                  _description.text = offre.description ?? '';
                  _ville.text = offre.ville ?? '';
                  _region = offre.region;
                  _typeContrat = offre.typeContrat;
                  _salaireMin.text = offre.salaireMin?.toString() ?? '';
                  _salaireMax.text = offre.salaireMax?.toString() ?? '';
                  _initialized = true;
                }
                return form();
              },
            )
          : form(),
    );
  }
}
