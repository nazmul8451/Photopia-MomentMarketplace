import 'package:photopia/core/network/urls.dart';

enum ChatMessageType {
  text,
  file,
  image,
  video,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  error,
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
  final MessageStatus status;
  final bool isLocal;

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
    this.status = MessageStatus.sent,
    this.isLocal = false,
  });

  ChatMessage copyWith({
    String? id,
    MessageStatus? status,
    bool? isLocal,
    String? fileUrl,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId,
      text: text,
      fileName: fileName,
      fileSize: fileSize,
      fileUrl: fileUrl ?? this.fileUrl,
      time: time,
      type: type,
      isMe: isMe,
      status: status ?? this.status,
      isLocal: isLocal ?? this.isLocal,
    );
  }

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

    // 4. File/Media Detection
    String? fUrl = json['fileUrl']?.toString() ?? json['image']?.toString() ?? json['video']?.toString() ?? json['file']?.toString();
    
    // Convert relative paths to full URLs
    if (fUrl != null && fUrl.isNotEmpty && !fUrl.startsWith('http')) {
      final String baseUrl = Urls.baseUrl.endsWith('/') 
          ? Urls.baseUrl.substring(0, Urls.baseUrl.length - 1) 
          : Urls.baseUrl;
      final String path = fUrl.startsWith('/') ? fUrl : '/$fUrl';
      fUrl = "$baseUrl$path";
    }

    ChatMessageType msgType = ChatMessageType.text;
    
    final String rawType = (json['type'] ?? '').toString().toLowerCase();
    if (json['image'] != null || rawType == 'image') {
      msgType = ChatMessageType.image;
    } else if (json['video'] != null || rawType == 'video') {
      msgType = ChatMessageType.video;
    } else if (json['file'] != null || rawType == 'file' || (fUrl != null && fUrl.isNotEmpty && msgType == ChatMessageType.text)) {
      msgType = ChatMessageType.file;
    }

    return ChatMessage(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      senderId: senderId,
      text: messageText,
      fileName: json['fileName']?.toString() ?? (fUrl != null ? fUrl.split('/').last : null),
      fileSize: json['fileSize']?.toString(),
      fileUrl: fUrl,
      time: (DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now()).toLocal(),
      type: msgType,
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
