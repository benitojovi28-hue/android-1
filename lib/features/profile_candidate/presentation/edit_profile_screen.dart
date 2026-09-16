import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/utils/region_cameroun.dart';
import 'package:mywork/core/widgets/app_field.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/features/auth/application/auth_providers.dart';
import 'package:mywork/features/profile_candidate/application/profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prenom = TextEditingController();
  final _nom = TextEditingController();
  final _email = TextEditingController();
  final _telephone = TextEditingController();
  final _titre = TextEditingController();
  final _ville = TextEditingController();

  String? _region;
  String? _existingPhotoUrl;
  String? _newPhotoName;
  Uint8List? _newPhotoBytes;
  bool _loading = false;
  bool _initialized = false;

  @override
  void dispose() {
    _prenom.dispose();
    _nom.dispose();
    _email.dispose();
    _telephone.dispose();
    _titre.dispose();
    _ville.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (files.isNotEmpty) {
      final bytes = await files.first.readAsBytes();
      setState(() {
        _newPhotoName = files.first.name;
        _newPhotoBytes = bytes;
      });
    }
  }

  Future<void> _save(String candidatId) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      String? photoUrl;
      if (_newPhotoBytes != null && _newPhotoName != null) {
        final userId = ref.read(currentUserProvider)?.id;
        if (userId != null) {
          photoUrl = await ref.read(candidateProfileRepositoryProvider).uploadDocument(
                folderId: userId,
                filename: _newPhotoName!,
                bytes: _newPhotoBytes!,
                contentType: 'image/${_newPhotoName!.split('.').last.toLowerCase()}',
              );
        }
      }

      await ref.read(candidateProfileRepositoryProvider).updateProfile(candidatId, {
        'prenom': _prenom.text.trim(),
        'nom': _nom.text.trim(),
        'email': _email.text.trim(),
        'telephone': _telephone.text.trim(),
        'titre_professionnel': _titre.text.trim(),
        'ville': _ville.text.trim(),
        'region': _region,
        if (photoUrl != null) 'photo_url': photoUrl,
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
            _email.text = profile.email ?? '';
            _telephone.text = profile.telephone ?? '';
            _titre.text = profile.titreProfessionnel ?? '';
            _ville.text = profile.ville ?? '';
            _region = RegionCameroun.fromDb(profile.region)?.dbValue;
            _existingPhotoUrl = profile.photoUrl;
            _initialized = true;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: CircleAvatar(
                        radius: 44,
                        backgroundImage: _newPhotoBytes != null
                            ? MemoryImage(_newPhotoBytes!)
                            : null,
                        child: _newPhotoBytes == null
                            ? Icon(
                                _existingPhotoUrl != null ? Icons.person : Icons.add_a_photo_outlined,
                                size: 32,
                              )
                            : null,
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: _pickPhoto,
                      child: Text(_newPhotoName ?? 'Changer la photo'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppField(controller: _prenom, label: 'Prénom'),
                  const SizedBox(height: 16),
                  AppField(controller: _nom, label: 'Nom'),
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
                  AppField(controller: _titre, label: 'Titre professionnel'),
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
            ),
          );
        },
      ),
    );
  }
}
