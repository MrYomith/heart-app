class ChatMessage {
  final int id;
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
}
