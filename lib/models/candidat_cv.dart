/// An uploaded CV file (candidat_cvs row).
class CandidatCvFile {
  const CandidatCvFile({
    required this.id,
    required this.nom,
    required this.fichierUrl,
    this.taille,
    this.mime,
    this.parDefaut = false,
    this.createdAt,
  });

  final String id;
  final String nom;
  final String fichierUrl;
  final int? taille;
  final String? mime;
  final bool parDefaut;
  final DateTime? createdAt;

  factory CandidatCvFile.fromMap(Map<String, dynamic> map) {
    return CandidatCvFile(
      id: map['id'] as String,
      nom: map['nom'] as String? ?? 'CV',
      fichierUrl: map['fichier_url'] as String,
      taille: map['taille'] as int?,
      mime: map['mime'] as String?,
      parDefaut: map['par_defaut'] as bool? ?? false,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
    );
  }
}
