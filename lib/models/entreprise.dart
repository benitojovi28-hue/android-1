class Entreprise {
  const Entreprise({
    required this.id,
    required this.userId,
    this.nom,
    this.email,
    this.telephone,
    this.logoUrl,
    this.secteur,
    this.region,
    this.ville,
    this.description,
    this.verificationStatut,
    this.numeroPublic,
    this.compteStatut,
  });

  final String id;
  final String userId;
  final String? nom;
  final String? email;
  final String? telephone;
  final String? logoUrl;
  final String? secteur;
  final String? region;
  final String? ville;
  final String? description;
  final String? verificationStatut;
  final String? numeroPublic;
  final String? compteStatut;

  factory Entreprise.fromMap(Map<String, dynamic> map) {
    return Entreprise(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      nom: map['nom'] as String?,
      email: map['email'] as String?,
      telephone: map['telephone'] as String?,
      logoUrl: map['logo_url'] as String?,
      secteur: map['secteur'] as String?,
      region: map['region'] as String?,
      ville: map['ville'] as String?,
      description: map['description'] as String?,
      verificationStatut: map['verification_statut'] as String?,
      numeroPublic: map['numero_public']?.toString(),
      compteStatut: map['compte_statut'] as String?,
    );
  }
}
