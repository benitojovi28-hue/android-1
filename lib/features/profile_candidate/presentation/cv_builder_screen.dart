import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/widgets/app_field.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';

class _Experience {
  _Experience({required this.poste, required this.entreprise, this.periode, this.description});

  final String poste;
  final String entreprise;
  final String? periode;
  final String? description;

  factory _Experience.fromMap(Map<String, dynamic> map) => _Experience(
        poste: map['poste'] as String? ?? '',
        entreprise: map['entreprise'] as String? ?? '',
        periode: map['periode'] as String?,
        description: map['description'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'poste': poste,
        'entreprise': entreprise,
        'periode': periode,
        'description': description,
      };
}

class _Formation {
  _Formation({required this.diplome, required this.etablissement, this.periode});

  final String diplome;
  final String etablissement;
  final String? periode;

  factory _Formation.fromMap(Map<String, dynamic> map) => _Formation(
        diplome: map['diplome'] as String? ?? '',
        etablissement: map['etablissement'] as String? ?? '',
        periode: map['periode'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'diplome': diplome,
        'etablissement': etablissement,
        'periode': periode,
      };
}

class _Langue {
  _Langue({required this.langue, required this.niveau});

  final String langue;
  final String niveau;

  factory _Langue.fromMap(Map<String, dynamic> map) => _Langue(
        langue: map['langue'] as String? ?? '',
        niveau: map['niveau'] as String? ?? niveaux.first,
      );

  Map<String, dynamic> toMap() => {'langue': langue, 'niveau': niveau};

  static const niveaux = ['Débutant', 'Intermédiaire', 'Avancé', 'Courant', 'Natif'];
}

/// Structured "CV MyWork" builder — backs the candidat_cv jsonb columns
/// (profil_pro, experiences, formations, competences, langues) with real
/// add/edit/remove sections instead of a single free-text field.
class CvBuilderScreen extends ConsumerStatefulWidget {
  const CvBuilderScreen({super.key});

  @override
  ConsumerState<CvBuilderScreen> createState() => _CvBuilderScreenState();
}

class _CvBuilderScreenState extends ConsumerState<CvBuilderScreen> {
  final _profilPro = TextEditingController();
  final _experiences = <_Experience>[];
  final _formations = <_Formation>[];
  final _competences = <String>[];
  final _langues = <_Langue>[];
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _profilPro.dispose();
    super.dispose();
  }

  void _initFromData(Map<String, dynamic>? data) {
    if (_initialized) return;
    _profilPro.text = data?['profil_pro'] as String? ?? '';
    _experiences.addAll(
      ((data?['experiences'] as List?) ?? const []).map((e) => _Experience.fromMap(e as Map<String, dynamic>)),
    );
    _formations.addAll(
      ((data?['formations'] as List?) ?? const []).map((e) => _Formation.fromMap(e as Map<String, dynamic>)),
    );
    _competences.addAll(((data?['competences'] as List?) ?? const []).cast<String>());
    _langues.addAll(
      ((data?['langues'] as List?) ?? const []).map((e) => _Langue.fromMap(e as Map<String, dynamic>)),
    );
    _initialized = true;
  }

  Future<void> _save(String candidatId) async {
    setState(() => _loading = true);
    try {
      await ref.read(candidateProfileRepositoryProvider).saveCvNumerique(candidatId, {
        'profil_pro': _profilPro.text.trim(),
        'experiences': _experiences.map((e) => e.toMap()).toList(),
        'formations': _formations.map((f) => f.toMap()).toList(),
        'competences': _competences,
        'langues': _langues.map((l) => l.toMap()).toList(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CV MyWork enregistré.')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addExperience() async {
    final poste = TextEditingController();
    final entreprise = TextEditingController();
    final periode = TextEditingController();
    final description = TextEditingController();
    final added = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une expérience'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppField(controller: poste, label: 'Poste'),
              const SizedBox(height: 12),
              AppField(controller: entreprise, label: 'Entreprise'),
              const SizedBox(height: 12),
              AppField(controller: periode, label: 'Période (ex : 2021 - 2023)'),
              const SizedBox(height: 12),
              AppField(controller: description, label: 'Description', maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Ajouter')),
        ],
      ),
    );
    if (added == true && poste.text.trim().isNotEmpty) {
      setState(() => _experiences.add(_Experience(
            poste: poste.text.trim(),
            entreprise: entreprise.text.trim(),
            periode: periode.text.trim().isEmpty ? null : periode.text.trim(),
            description: description.text.trim().isEmpty ? null : description.text.trim(),
          )));
    }
  }

  Future<void> _addFormation() async {
    final diplome = TextEditingController();
    final etablissement = TextEditingController();
    final periode = TextEditingController();
    final added = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une formation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppField(controller: diplome, label: 'Diplôme'),
              const SizedBox(height: 12),
              AppField(controller: etablissement, label: 'Établissement'),
              const SizedBox(height: 12),
              AppField(controller: periode, label: 'Période (ex : 2018 - 2021)'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Ajouter')),
        ],
      ),
    );
    if (added == true && diplome.text.trim().isNotEmpty) {
      setState(() => _formations.add(_Formation(
            diplome: diplome.text.trim(),
            etablissement: etablissement.text.trim(),
            periode: periode.text.trim().isEmpty ? null : periode.text.trim(),
          )));
    }
  }

  Future<void> _addCompetence() async {
    final competence = TextEditingController();
    final added = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une compétence'),
        content: AppField(controller: competence, label: 'Compétence'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Ajouter')),
        ],
      ),
    );
    final value = competence.text.trim();
    if (added == true && value.isNotEmpty && !_competences.contains(value)) {
      setState(() => _competences.add(value));
    }
  }

  Future<void> _addLangue() async {
    final langue = TextEditingController();
    var niveau = _Langue.niveaux.first;
    final added = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ajouter une langue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppField(controller: langue, label: 'Langue'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: niveau,
                decoration: const InputDecoration(labelText: 'Niveau'),
                items: _Langue.niveaux.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                onChanged: (v) => setDialogState(() => niveau = v ?? niveau),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Ajouter')),
          ],
        ),
      ),
    );
    if (added == true && langue.text.trim().isNotEmpty) {
      setState(() => _langues.add(_Langue(langue: langue.text.trim(), niveau: niveau)));
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
          final cvAsync = ref.watch(cvNumeriqueProvider(profile.id));
          return cvAsync.when(
            loading: () => const AppLoader(),
            error: (e, _) => const Text('Erreur de chargement'),
            data: (data) {
              _initFromData(data);
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
                    _Section(
                      title: 'Expériences',
                      onAdd: _addExperience,
                      children: [
                        for (var i = 0; i < _experiences.length; i++)
                          _EntryTile(
                            title: _experiences[i].poste,
                            subtitle: [
                              _experiences[i].entreprise,
                              if (_experiences[i].periode != null) _experiences[i].periode!,
                            ].join(' · '),
                            onDelete: () => setState(() => _experiences.removeAt(i)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _Section(
                      title: 'Formations',
                      onAdd: _addFormation,
                      children: [
                        for (var i = 0; i < _formations.length; i++)
                          _EntryTile(
                            title: _formations[i].diplome,
                            subtitle: [
                              _formations[i].etablissement,
                              if (_formations[i].periode != null) _formations[i].periode!,
                            ].join(' · '),
                            onDelete: () => setState(() => _formations.removeAt(i)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _Section(
                      title: 'Compétences',
                      onAdd: _addCompetence,
                      children: [
                        if (_competences.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (var i = 0; i < _competences.length; i++)
                                Chip(
                                  label: Text(_competences[i]),
                                  onDeleted: () => setState(() => _competences.removeAt(i)),
                                ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _Section(
                      title: 'Langues',
                      onAdd: _addLangue,
                      children: [
                        for (var i = 0; i < _langues.length; i++)
                          _EntryTile(
                            title: _langues[i].langue,
                            subtitle: _langues[i].niveau,
                            onDelete: () => setState(() => _langues.removeAt(i)),
                          ),
                      ],
                    ),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.onAdd, required this.children});

  final String title;
  final VoidCallback onAdd;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: onAdd, tooltip: 'Ajouter'),
          ],
        ),
        if (children.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('Aucune entrée.', style: Theme.of(context).textTheme.bodySmall),
          )
        else
          ...children,
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.title, required this.subtitle, required this.onDelete});

  final String title;
  final String subtitle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
    );
  }
}
