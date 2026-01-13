enum ChatMessageType {
  text,
  file,
  image,
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final String? fileName;
  final String? fileSize;
  final String? fileUrl;
  final DateTime time;
  final ChatMessageType type;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.fileName,
    this.fileSize,
    this.fileUrl,
    required this.time,
    required this.type,
    required this.isMe,
  });
}
