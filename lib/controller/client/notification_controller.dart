import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationController extends ChangeNotifier {
  static NotificationController? _instance;
  static NotificationController get instance {
    _instance ??= NotificationController();
    return _instance!;
  }

  NotificationController() {
    _instance = this;
  }

  bool _isLoading = false;
  String? _errorMessage;
  List<NotificationModel> _notifications = [];
  NotificationStats? _stats;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<NotificationModel> get notifications => _notifications;
  NotificationStats? get stats => _stats;

  int get unreadCount => _stats?.unread ?? _notifications.where((n) => !n.isRead).length;

  Future<void> fetchMyNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(url: Urls.getMyNotification);
      if (response.isSuccess && response.body != null) {
        final dynamic rawData = response.body?['data'];
        List<dynamic> dataList = [];
        
        if (rawData is List) {
          dataList = rawData;
        } else if (rawData is Map && rawData['data'] is List) {
          dataList = rawData['data'];
        }
        
        _notifications = dataList.map((item) => NotificationModel.fromJson(item)).toList();
        await fetchNotificationStats(); // Also update stats
      } else {
        _errorMessage = response.errorMessage ?? "Failed to fetch notifications";
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
      debugPrint("fetchMyNotifications error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNotificationStats() async {
    try {
      final response = await NetworkCaller.getRequest(url: Urls.getNotificationStats);
      if (response.isSuccess && response.body != null && response.body!['data'] is Map) {
        _stats = NotificationStats.fromJson(response.body!['data']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("fetchNotificationStats error: $e");
    }
  }

  Future<void> markAllAsRead() async {
    final response = await NetworkCaller.patchRequest(url: Urls.markAllNotificationsAsRead, body: {});
    if (response.isSuccess) {
      for (var i = 0; i < _notifications.length; i++) {
        final n = _notifications[i];
        _notifications[i] = NotificationModel(
          id: n.id, userId: n.userId, title: n.title, content: n.content,
          type: n.type, isRead: true, createdAt: n.createdAt, actionUrl: n.actionUrl
        );
      }
      _stats = NotificationStats(total: _stats?.total ?? 0, unread: 0, byType: _stats?.byType);
      notifyListeners();
    }
  }

  Future<void> markSingleAsRead(String id) async {
    final response = await NetworkCaller.patchRequest(url: Urls.markSingleNotificationAsRead(id), body: {});
    if (response.isSuccess) {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final n = _notifications[index];
        _notifications[index] = NotificationModel(
          id: n.id, userId: n.userId, title: n.title, content: n.content,
          type: n.type, isRead: true, createdAt: n.createdAt, actionUrl: n.actionUrl
        );
        if (_stats != null && _stats!.unread > 0) {
          _stats = NotificationStats(total: _stats!.total, unread: _stats!.unread - 1, byType: _stats!.byType);
        }
        notifyListeners();
      }
    }
  }

  void onNewNotification(dynamic data) {
    debugPrint("Socket Payload for Notification: $data");
    if (data != null && data['type'] == 'NEW_NOTIFICATION') {
      final notificationData = data['data'];
      if (notificationData != null) {
        final newNotification = NotificationModel.fromJson(notificationData);
        _notifications.insert(0, newNotification);
        
        // Update stats locally
        _stats = NotificationStats(
          total: (_stats?.total ?? 0) + 1,
          unread: (_stats?.unread ?? 0) + 1,
          byType: _stats?.byType
        );
        notifyListeners();
      }
    }
  }

  void removeNotification(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  String formatTime(DateTime date) {
    return timeago.format(date);
  }

  IconData getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'booking':
        return Icons.calendar_today_outlined;
      case 'message':
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'payment':
        return Icons.check_circle_outline;
      case 'favorite':
      case 'price_drop':
        return Icons.favorite_border;
      case 'review':
        return Icons.star_border;
      default:
        return Icons.notifications_none_outlined;
    }
  }
}
