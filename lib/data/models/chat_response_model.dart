import 'package:photopia/data/models/professional_profile_model.dart';
import 'package:photopia/data/models/conversation_model.dart';
import 'package:photopia/data/models/chat_message_model.dart';

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

    final bool isLastMessageFromMe = latestMessage?.sender == currentUserId;
    
    MessageStatus resolveStatus() {
      if (latestMessage?.isSeen == true || latestMessage?.status == 'read') {
        return MessageStatus.read;
      }
      if (latestMessage?.status == 'delivered') {
        return MessageStatus.delivered;
      }
      return MessageStatus.sent;
    }

    return Conversation(
      id: sId ?? '',
      name: otherParticipant?.name ?? 'Unknown',
      lastMessage: latestMessage?.content ?? '',
      avatarUrl: otherParticipant?.profile ?? '',
      lastMessageTime: (DateTime.tryParse(latestMessage?.createdAt ?? '') ?? DateTime.now()).toLocal(),
      unreadCount: unreadCount ?? 0,
      isOnline: false,
      status: resolveStatus(),
      receiverId: otherParticipant?.sId,
      isLastMessageFromMe: isLastMessageFromMe,
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
  bool isSeen = false;
  String? status;

  LatestMessage({this.sId, this.content, this.sender, this.createdAt, this.isSeen = false, this.status});

  LatestMessage.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    
    final String text = (json['text'] ?? json['message'] ?? json['content'] ?? json['body'] ?? '').toString();
    final String? image = json['image']?.toString();
    final String? video = json['video']?.toString();
    final String? file = json['file']?.toString() ?? json['fileUrl']?.toString();

    if (image != null && image.isNotEmpty) {
      content = text.isNotEmpty ? "📷 $text" : "📷 Photo";
    } else if (video != null && video.isNotEmpty) {
      content = text.isNotEmpty ? "🎥 $text" : "🎥 Video";
    } else if (file != null && file.isNotEmpty) {
      content = text.isNotEmpty ? "📁 $text" : "📁 Attachment";
    } else {
      content = text;
    }
    
    if (json['senderId'] is Map) {
      sender = json['senderId']['_id']?.toString() ?? json['senderId']['id']?.toString() ?? '';
    } else if (json['sender'] is Map) {
      sender = json['sender']['_id']?.toString() ?? json['sender']['id']?.toString() ?? '';
    } else {
      sender = json['senderId']?.toString() ?? json['sender']?.toString();
    }
    createdAt = json['createdAt'];
    isSeen = json['isSeen'] ?? json['read'] ?? false;
    status = json['status']?.toString().toLowerCase();
  }
}
