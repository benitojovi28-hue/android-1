import 'offre.dart';

class Candidature {
  const Candidature({
    required this.id,
    required this.createdAt,
    required this.statut,
    this.message,
    this.cvId,
    this.cvNom,
    this.cvChemin,
    this.cvUrl,
    this.cvNumerique,
    this.entretienAt,
    this.candidatNom,
    this.candidatEmail,
    this.candidatTelephone,
    this.offre,
    this.employeFinDeclareeAt,
    this.employeurFinConfirmeeAt,
  });

  final String id;
  final DateTime createdAt;
  final String statut;
  final String? message;
  final String? cvId;
  final String? cvNom;
  final String? cvChemin;
  final String? cvUrl;
  final Map<String, dynamic>? cvNumerique;
  final DateTime? entretienAt;
  final String? candidatNom;
  final String? candidatEmail;
  final String? candidatTelephone;
  final Offre? offre;
  final DateTime? employeFinDeclareeAt;
  final DateTime? employeurFinConfirmeeAt;

  bool get usesCvNumerique => cvNumerique != null;

  factory Candidature.fromMap(Map<String, dynamic> map) {
    final offreMap = map['offre'] as Map<String, dynamic>?;
    return Candidature(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      statut: map['statut'] as String? ?? 'envoyee',
      message: map['message'] as String?,
      cvId: map['cv_id'] as String?,
      cvNom: map['cv_nom'] as String?,
      cvChemin: map['cv_chemin'] as String?,
      cvUrl: map['cv_url'] as String?,
      cvNumerique: map['cv_numerique'] as Map<String, dynamic>?,
      entretienAt: map['entretien_at'] != null
          ? DateTime.tryParse(map['entretien_at'] as String)
          : null,
      candidatNom: map['candidat_nom'] as String?,
      candidatEmail: map['candidat_email'] as String?,
      candidatTelephone: map['candidat_telephone'] as String?,
      offre: offreMap != null ? Offre.fromMap(offreMap) : null,
      employeFinDeclareeAt: map['employe_fin_declaree_at'] != null
          ? DateTime.tryParse(map['employe_fin_declaree_at'] as String)
          : null,
      employeurFinConfirmeeAt: map['employeur_fin_confirmee_at'] != null
          ? DateTime.tryParse(map['employeur_fin_confirmee_at'] as String)
          : null,
    );
  }
}
