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
    latestMessage = json['latestMessage'] != null
        ? LatestMessage.fromJson(json['latestMessage'])
        : null;
    unreadCount = json['unreadCount'] ?? 0;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
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
    profile = json['profile'];
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
    content = json['message']; // Backend uses 'message' or 'content'? Postman screenshot doesn't show. I'll use 'message' based on common patterns.
    // wait, if Postman shows empty chats, I don't know the keys.
    // I'll use common keys and adjust if needed.
    sender = json['senderId'];
    createdAt = json['createdAt'];
  }
}
