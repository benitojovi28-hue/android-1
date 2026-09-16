class AlerteCandidat {
  const AlerteCandidat({
    required this.id,
    this.libelle,
    this.motsCles,
    this.metier,
    this.secteur,
    this.region,
    this.ville,
    this.typeContrat,
    this.salaireMin,
    this.actif = true,
  });

  final String id;
  final String? libelle;
  final String? motsCles;
  final String? metier;
  final String? secteur;
  final String? region;
  final String? ville;
  final String? typeContrat;
  final num? salaireMin;
  final bool actif;

  factory AlerteCandidat.fromMap(Map<String, dynamic> map) {
    return AlerteCandidat(
      id: map['id'] as String,
      libelle: map['libelle'] as String?,
      motsCles: map['mots_cles'] as String?,
      metier: map['metier'] as String?,
      secteur: map['secteur'] as String?,
      region: map['region'] as String?,
      ville: map['ville'] as String?,
      typeContrat: map['type_contrat'] as String?,
      salaireMin: map['salaire_min'] as num?,
      actif: map['actif'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toInsertMap(String candidatId) => {
        'candidat_id': candidatId,
        'libelle': libelle,
        'mots_cles': motsCles,
        'metier': metier,
        'secteur': secteur,
        'region': region,
        'ville': ville,
        'type_contrat': typeContrat,
        'salaire_min': salaireMin,
        'actif': actif,
      };
}
