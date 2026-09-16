class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  /// support_msg_role enum: user | assistant | agent | system
  final String role;
  final String content;
  final DateTime createdAt;

  bool get isFromUser => role == 'user';

  factory SupportMessage.fromMap(Map<String, dynamic> map) {
    return SupportMessage(
      id: map['id'] as String,
      conversationId: map['conversation_id'] as String,
      role: map['role'] as String? ?? 'user',
      content: map['content'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
