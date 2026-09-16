import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mywork/core/widgets/app_card.dart';
import 'package:mywork/core/widgets/app_loader.dart';
import 'package:mywork/core/widgets/empty_state.dart';
import 'package:mywork/features/applications/application/candidatures_providers.dart';

class MyCvsScreen extends ConsumerStatefulWidget {
  const MyCvsScreen({super.key});

  @override
  ConsumerState<MyCvsScreen> createState() => _MyCvsScreenState();
}

class _MyCvsScreenState extends ConsumerState<MyCvsScreen> {
  bool _uploading = false;

  Future<void> _upload() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (files.isEmpty) return;
    final file = files.first;
    final bytes = await file.readAsBytes();

    setState(() => _uploading = true);
    try {
      await ref.read(candidaturesRepositoryProvider).addCv(
            bytes: bytes,
            filename: file.name,
            mime: 'application/octet-stream',
          );
      ref.invalidate(myCvsProvider);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cvsAsync = ref.watch(myCvsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes CV')),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploading ? null : _upload,
        child: _uploading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
            : const Icon(Icons.add),
      ),
      body: cvsAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const EmptyState(icon: Icons.error_outline, title: 'Erreur de chargement'),
        data: (cvs) {
          if (cvs.isEmpty) {
            return const EmptyState(icon: Icons.folder_open, title: 'Aucun CV téléversé');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cvs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cv = cvs[index];
              return AppCard(
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined),
                    const SizedBox(width: 12),
                    Expanded(child: Text(cv.nom, overflow: TextOverflow.ellipsis)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await ref.read(candidaturesRepositoryProvider).deleteCv(cv.id);
                        ref.invalidate(myCvsProvider);
                      },
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
