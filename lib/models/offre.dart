class Offre {
  const Offre({
    required this.id,
    this.entrepriseId,
    required this.titre,
    this.description,
    this.entrepriseNom,
    this.secteur,
    this.categorie,
    this.typeContrat,
    this.region,
    this.ville,
    this.quartier,
    this.salaireMin,
    this.salaireMax,
    this.salaireTexte,
    this.devise,
    this.experienceTexte,
    this.datePublication,
    this.dateExpiration,
    this.statut,
    this.nombrePostes,
  });

  final String id;
  final String? entrepriseId;
  final String titre;
  final String? description;
  final String? entrepriseNom;
  final String? secteur;
  final String? categorie;
  final String? typeContrat;
  final String? region;
  final String? ville;
  final String? quartier;
  final num? salaireMin;
  final num? salaireMax;
  final String? salaireTexte;
  final String? devise;
  final String? experienceTexte;
  final DateTime? datePublication;
  final DateTime? dateExpiration;
  final String? statut;
  final int? nombrePostes;

  factory Offre.fromMap(Map<String, dynamic> map) {
    return Offre(
      id: map['id'] as String,
      entrepriseId: map['entreprise_id'] as String?,
      titre: map['titre'] as String? ?? '',
      description: map['description'] as String?,
      entrepriseNom: map['entreprise_nom'] as String?,
      secteur: map['secteur'] as String?,
      categorie: map['categorie'] as String?,
      typeContrat: map['type_contrat'] as String?,
      region: map['region'] as String?,
      ville: map['ville'] as String?,
      quartier: map['quartier'] as String?,
      salaireMin: map['salaire_min'] as num?,
      salaireMax: map['salaire_max'] as num?,
      salaireTexte: map['salaire_texte'] as String?,
      devise: map['devise'] as String?,
      experienceTexte: map['experience_texte'] as String?,
      datePublication: map['date_publication'] != null
          ? DateTime.tryParse(map['date_publication'] as String)
          : null,
      dateExpiration: map['date_expiration'] != null
          ? DateTime.tryParse(map['date_expiration'] as String)
          : null,
      statut: map['statut'] as String?,
      nombrePostes: map['nombre_postes'] as int?,
    );
  }
}
