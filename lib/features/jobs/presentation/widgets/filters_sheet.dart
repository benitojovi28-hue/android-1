import 'package:flutter/material.dart';

import 'package:mywork/core/utils/region_cameroun.dart';
import 'package:mywork/features/jobs/data/offres_repository.dart';

Future<OffresSearchFilters?> showJobFiltersSheet(
  BuildContext context,
  OffresSearchFilters current,
) {
  return showModalBottomSheet<OffresSearchFilters>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _FiltersSheetContent(current: current),
  );
}

class _FiltersSheetContent extends StatefulWidget {
  const _FiltersSheetContent({required this.current});

  final OffresSearchFilters current;

  @override
  State<_FiltersSheetContent> createState() => _FiltersSheetContentState();
}

class _FiltersSheetContentState extends State<_FiltersSheetContent> {
  String? _region;
  String? _typeContrat;
  late final TextEditingController _ville;

  static const _contrats = ['CDI', 'CDD', 'Stage', 'Freelance', 'Intérim'];

  @override
  void initState() {
    super.initState();
    _region = widget.current.region;
    _typeContrat = widget.current.typeContrat;
    _ville = TextEditingController(text: widget.current.ville ?? '');
  }

  @override
  void dispose() {
    _ville.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filtres', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _ville,
            decoration: const InputDecoration(labelText: 'Ville'),
          ),
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(
                OffresSearchFilters(
                  query: widget.current.query,
                  region: _region,
                  ville: _ville.text.trim().isEmpty ? null : _ville.text.trim(),
                  typeContrat: _typeContrat,
                ),
              );
            },
            child: const Text('Appliquer'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(const OffresSearchFilters()),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }
}
