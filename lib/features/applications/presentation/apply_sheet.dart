import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/widgets/app_field.dart';
import 'package:mywork/models/candidat_cv.dart';
import 'package:mywork/features/applications/application/candidatures_providers.dart';

Future<bool?> showApplySheet(BuildContext context, {required String offreId}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _ApplySheetContent(offreId: offreId),
  );
}

class _ApplySheetContent extends ConsumerStatefulWidget {
  const _ApplySheetContent({required this.offreId});

  final String offreId;

  @override
  ConsumerState<_ApplySheetContent> createState() => _ApplySheetContentState();
}

class _ApplySheetContentState extends ConsumerState<_ApplySheetContent> {
  final _message = TextEditingController();
  String? _selectedCvId;
  bool _useCvNumerique = false;
  String? _newFileName;
  Uint8List? _newFileBytes;
  bool _loading = false;
  String? _error;

  Future<void> _pickFile() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (files.isNotEmpty) {
      final bytes = await files.first.readAsBytes();
      setState(() {
        _newFileName = files.first.name;
        _newFileBytes = bytes;
        _selectedCvId = null;
        _useCvNumerique = false;
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref.read(candidaturesRepositoryProvider).apply(
            offreId: widget.offreId,
            cvId: _selectedCvId,
            cvNumerique: _useCvNumerique,
            cvFichierBytes: _newFileBytes,
            cvFichierNom: _newFileName,
            message: _message.text.trim().isEmpty ? null : _message.text.trim(),
          );

      if (result['ok'] == true) {
        ref.invalidate(myApplicationsProvider);
        if (mounted) Navigator.of(context).pop(true);
        return;
      }

      if (result['duplicate'] == true) {
        setState(() => _error = 'Vous avez déjà postulé à cette offre.');
      } else if (result['cvManquant'] == true) {
        setState(() => _error = 'Choisissez ou téléversez un CV.');
      } else if (result['cvMyworkManquant'] == true) {
        setState(() => _error = "Complétez d'abord votre CV MyWork.");
      } else if (result['manquants'] != null) {
        setState(() => _error = 'Complétez votre profil (nom, email, téléphone) avant de postuler.');
      } else {
        setState(() => _error = 'Candidature impossible.');
      }
    } catch (e) {
      setState(() => _error = "Une erreur est survenue. Réessayez.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cvsAsync = ref.watch(myCvsProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Postuler', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            cvsAsync.when(
              data: (cvs) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RadioListTile<bool>(
                    value: true,
                    groupValue: _useCvNumerique,
                    title: const Text('CV MyWork (en ligne)'),
                    onChanged: (v) => setState(() {
                      _useCvNumerique = true;
                      _selectedCvId = null;
                      _newFileName = null;
                      _newFileBytes = null;
                    }),
                  ),
                  for (final CandidatCvFile cv in cvs)
                    RadioListTile<String>(
                      value: cv.id,
                      groupValue: _selectedCvId,
                      title: Text(cv.nom),
                      onChanged: (v) => setState(() {
                        _selectedCvId = v;
                        _useCvNumerique = false;
                        _newFileName = null;
                        _newFileBytes = null;
                      }),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file),
                    label: Text(_newFileName ?? 'Téléverser un nouveau CV'),
                  ),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => const Text('Impossible de charger vos CV.'),
            ),
            const SizedBox(height: 16),
            AppField(
              controller: _message,
              label: 'Message (optionnel)',
              maxLines: 3,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Envoyer ma candidature'),
            ),
          ],
        ),
      ),
    );
  }
}
