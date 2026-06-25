class ChatMessage {
  final String id;
  final String sender;
  final String avatar;
  final String sentAt;
  final String subject;
  final String preview;
  final String body;
  final bool isRead;
  final String category;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.avatar,
    required this.sentAt,
    required this.subject,
    required this.preview,
    this.body = '',
    this.isRead = true,
    this.category = 'All',
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'].toString(),
        sender: (j['sender'] as String?) ?? 'Care Team',
        avatar: (j['avatar'] as String?) ?? '🫀',
        sentAt: _relative(j['sent_at'] as String?),
        subject: (j['subject'] as String?) ?? 'Message',
        preview: (j['preview'] as String?) ?? '',
        body: (j['body'] as String?) ?? '',
        isRead: (j['is_read'] as bool?) ?? false,
        category: (j['category'] as String?) ?? 'Support',
      );

  ChatMessage copyWith({bool? isRead}) => ChatMessage(
        id: id, sender: sender, avatar: avatar, sentAt: sentAt, subject: subject,
        preview: preview, body: body, isRead: isRead ?? this.isRead, category: category,
      );

  static String _relative(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}.${dt.month}.${dt.year}';
  }
}
