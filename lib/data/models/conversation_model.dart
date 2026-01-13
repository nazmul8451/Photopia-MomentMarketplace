class Conversation {
  final String id;
  final String name;
  final String lastMessage;
  final String avatarUrl;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final MessageStatus status;

  Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.avatarUrl,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.status = MessageStatus.sent,
  });
}

enum MessageStatus {
  sent,
  delivered,
  read,
}
