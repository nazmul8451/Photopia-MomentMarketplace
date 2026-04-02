import 'package:photopia/data/models/professional_profile_model.dart';
import 'package:photopia/data/models/conversation_model.dart';

class ChatResponse {
  int? statusCode;
  bool? success;
  String? message;
  ChatData? data;

  ChatResponse({this.statusCode, this.success, this.message, this.data});

  ChatResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? ChatData.fromJson(json['data']) : null;
  }
}

class ChatData {
  List<ChatRoom>? chats;
  int? totalUnreadChats;

  ChatData({this.chats, this.totalUnreadChats});

  ChatData.fromJson(Map<String, dynamic> json) {
    if (json['chats'] != null) {
      chats = <ChatRoom>[];
      json['chats'].forEach((v) {
        chats!.add(ChatRoom.fromJson(v));
      });
    }
    totalUnreadChats = json['totalUnreadChats'];
  }
}

class ChatRoom {
  String? sId;
  List<ChatParticipant>? participants;
  LatestMessage? latestMessage;
  int? unreadCount;
  String? createdAt;
  String? updatedAt;

  ChatRoom({
    this.sId,
    this.participants,
    this.latestMessage,
    this.unreadCount,
    this.createdAt,
    this.updatedAt,
  });

  ChatRoom.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['participants'] != null) {
      participants = <ChatParticipant>[];
      json['participants'].forEach((v) {
        participants!.add(ChatParticipant.fromJson(v));
      });
    }
    final latestMsgData = json['latestMessage'] ?? json['lastMessage'] ?? json['message'] ?? json['latest_message'] ?? json['last_message'];
    
    if (latestMsgData != null) {
      if (latestMsgData is Map) {
        latestMessage = LatestMessage.fromJson(latestMsgData as Map<String, dynamic>);
      } else if (latestMsgData is String) {
        latestMessage = LatestMessage(content: latestMsgData);
      }
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Conversation toConversation(String? currentUserId) {
    // Filter out the current user to find the other participant
    final otherParticipant = participants?.firstWhere(
      (p) => p.sId != currentUserId,
      orElse: () => participants?.first ?? ChatParticipant(),
    );

    return Conversation(
      id: sId ?? '',
      name: otherParticipant?.name ?? 'Unknown',
      lastMessage: latestMessage?.content ?? '',
      avatarUrl: otherParticipant?.profile ?? '',
      lastMessageTime: (DateTime.tryParse(latestMessage?.createdAt ?? '') ?? DateTime.now()).toLocal(),
      unreadCount: unreadCount ?? 0,
      isOnline: false,
      status: MessageStatus.read, // UI fallback
      receiverId: otherParticipant?.sId,
    );
  }
}

class ChatParticipant {
  String? sId;
  String? name;
  String? email;
  String? profile;

  ChatParticipant({this.sId, this.name, this.email, this.profile});

  ChatParticipant.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    profile = ProfessionalProfileModel.formatUrl(json['profile']);
  }
}

class LatestMessage {
  String? sId;
  String? content;
  String? sender;
  String? createdAt;

  LatestMessage({this.sId, this.content, this.sender, this.createdAt});

  LatestMessage.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    final msg = json['text'] ?? json['message'] ?? json['content'] ?? json['body'];
    if (msg is Map) {
      content = (msg['text'] ?? msg['message'] ?? msg['content'] ?? '').toString();
    } else {
      content = (msg ?? '').toString();
    }
    sender = json['senderId'];
    createdAt = json['createdAt'];
  }
}
