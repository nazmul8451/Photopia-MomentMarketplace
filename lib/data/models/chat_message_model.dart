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

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId, {String? roomReceiverId}) {
    // 1. Extract sender ID
    String senderId = '';
    final senderData = json['senderId'] ?? json['sender'] ?? json['userId'];
    if (senderData is String) {
      senderId = senderData;
    } else if (senderData is Map) {
      senderId = (senderData['_id'] ?? senderData['id'] ?? '').toString();
    }

    // 2. Extract message text (Check multiple keys)
    String messageText = '';
    if (json['text'] != null) {
      messageText = json['text'].toString();
    } else if (json['message'] != null) {
      messageText = json['message'].toString();
    } else if (json['content'] != null) {
      messageText = json['content'].toString();
    }

    if (messageText.isEmpty || messageText == 'null') {
      messageText = "[Empty Message]";
    }

    // 3. Robust Identity Logic for ALIGNMENT
    // - If currentUserId is provided, we use it.
    // - If not, we assume any message NOT from roomReceiverId is from ME.
    bool me = false;
    if (currentUserId.isNotEmpty) {
      me = senderId.trim().toLowerCase() == currentUserId.trim().toLowerCase();
    } else if (roomReceiverId != null && roomReceiverId.isNotEmpty) {
      me = senderId.trim().toLowerCase() != roomReceiverId.trim().toLowerCase();
    }

    return ChatMessage(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      senderId: senderId,
      text: messageText,
      time: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      type: json['image'] != null || json['type'] == 'image' ? ChatMessageType.image : ChatMessageType.text,
      isMe: me,
    );
  }
}

class MessageResponse {
  final int statusCode;
  final bool success;
  final String message;
  final List<ChatMessage> data;

  MessageResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json, String currentUserId, {String? roomReceiverId}) {
    return MessageResponse(
      statusCode: json['statusCode'] ?? 0,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((m) => ChatMessage.fromJson(m, currentUserId, roomReceiverId: roomReceiverId))
          .toList(),
    );
  }
}
