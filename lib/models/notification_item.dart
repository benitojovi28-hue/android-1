/// Unifies notifications_candidat and entreprise_notifications — same shape,
/// two separate source tables (no unified table exists in the schema).
class NotificationItem {
  const NotificationItem({
    required this.id,
    this.type,
    this.titre,
    this.message,
    this.lien,
    this.lu = false,
    this.createdAt,
    this.actionRequise = false,
  });

  final String id;
  final String? type;
  final String? titre;
  final String? message;
  final String? lien;
  final bool lu;
  final DateTime? createdAt;
  final bool actionRequise;

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'] as String,
      type: map['type'] as String?,
      titre: map['titre'] as String?,
      message: map['message'] as String?,
      lien: map['lien'] as String?,
      lu: map['lu'] as bool? ?? false,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
      actionRequise: map['action_requise'] as bool? ?? false,
    );
  }
}
