class Candidat {
  const Candidat({
    required this.id,
    required this.userId,
    this.nom,
    this.prenom,
    this.email,
    this.telephone,
    this.photoUrl,
    this.titreProfessionnel,
    this.region,
    this.ville,
    this.competences = const [],
    this.experienceAnnees,
    this.noteMoyenne,
    this.nbAvis,
    this.scoreCompletude,
    this.numeroPublic,
    this.compteStatut,
  });

  final String id;
  final String userId;
  final String? nom;
  final String? prenom;
  final String? email;
  final String? telephone;
  final String? photoUrl;
  final String? titreProfessionnel;
  final String? region;
  final String? ville;
  final List<String> competences;
  final int? experienceAnnees;
  final num? noteMoyenne;
  final int? nbAvis;
  final int? scoreCompletude;
  final String? numeroPublic;
  final String? compteStatut;

  String get displayName =>
      [prenom, nom].whereType<String>().where((e) => e.isNotEmpty).join(' ');

  factory Candidat.fromMap(Map<String, dynamic> map) {
    return Candidat(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      nom: map['nom'] as String?,
      prenom: map['prenom'] as String?,
      email: map['email'] as String?,
      telephone: map['telephone'] as String?,
      photoUrl: map['photo_url'] as String?,
      titreProfessionnel: map['titre_professionnel'] as String?,
      region: map['region'] as String?,
      ville: map['ville'] as String?,
      competences: (map['competences'] as List?)?.cast<String>() ?? const [],
      experienceAnnees: map['experience_annees'] as int?,
      noteMoyenne: map['note_moyenne'] as num?,
      nbAvis: map['nb_avis'] as int?,
      scoreCompletude: map['score_completude'] as int?,
      numeroPublic: map['numero_public']?.toString(),
      compteStatut: map['compte_statut'] as String?,
    );
  }
}
