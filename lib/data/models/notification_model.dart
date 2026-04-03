class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? actionUrl;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.actionUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user'] ?? '').toString(),
      title: json['title']?.toString() ?? 'Notification',
      content: (json['content'] ?? json['message'] ?? json['description'] ?? '').toString(),
      type: json['type']?.toString() ?? 'SYSTEM',
      isRead: json['isRead'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      actionUrl: json['actionUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'actionUrl': actionUrl,
    };
  }
}

class NotificationStats {
  final int total;
  final int unread;
  final Map<String, dynamic>? byType;

  NotificationStats({
    required this.total,
    required this.unread,
    this.byType,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      unread: int.tryParse(json['unread']?.toString() ?? '0') ?? 0,
      byType: json['byType'] is Map ? json['byType'] : null,
    );
  }
}
