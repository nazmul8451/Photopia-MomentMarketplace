import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _notifications = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => n['isUnread'] == true).length;

  Future<void> fetchMyNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(url: Urls.getMyNotification);
      if (response.isSuccess && response.body != null) {
        final List<dynamic> data = response.body?['data'] ?? [];
        _notifications = data.map((item) {
          return {
            '_id': item['_id'] ?? item['id'] ?? '',
            'title': item['title'] ?? 'Notification',
            'description': item['message'] ?? item['description'] ?? item['content'] ?? '',
            'timeAgo': _formatTime(item['createdAt'] ?? item['date']),
            'isUnread': item['isRead'] == false || item['isUnread'] == true,
            'type': item['type'] ?? 'system',
            'icon': _getIconForType(item['type']),
          };
        }).toList();
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

  void markAllAsRead() {
    for (var n in _notifications) {
      n['isUnread'] = false;
    }
    notifyListeners();
    // Optional: Call an API to mark all as read here
  }

  void removeNotification(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications.removeAt(index);
      notifyListeners();
      // Optional: Call an API to delete the notification
    }
  }

  String _formatTime(dynamic dateString) {
    if (dateString == null) return 'recently';
    try {
      final date = DateTime.parse(dateString.toString());
      return timeago.format(date);
    } catch (e) {
      return 'recently';
    }
  }

  IconData _getIconForType(String? type) {
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
