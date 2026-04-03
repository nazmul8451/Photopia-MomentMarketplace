import 'package:photopia/data/models/chat_message_model.dart';

class Conversation {
  final String id;
  final String name;
  final String lastMessage;
  final String avatarUrl;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final bool isTemporary;
  final MessageStatus status;
  final String? receiverId; // For temporary chats (provider's userId)

  Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.avatarUrl,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.status = MessageStatus.sent,
    this.isTemporary = false,
    this.receiverId,
  });
}
