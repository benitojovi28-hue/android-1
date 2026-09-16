class Avis {
  const Avis({
    required this.id,
    this.note,
    this.commentaire,
    this.createdAt,
  });

  final String id;
  final num? note;
  final String? commentaire;
  final DateTime? createdAt;

  factory Avis.fromMap(Map<String, dynamic> map) {
    return Avis(
      id: map['id'] as String,
      note: map['note'] as num?,
      commentaire: map['commentaire'] as String?,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
    );
  }
}
