import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';

// Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    debugPrint("🔔 NotificationService: Initializing...");

    // 1. Request Permission
    final NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint(
      "🔔 NotificationService: Permission Status: ${settings.authorizationStatus}",
    );

    // 2. Initialize Local Notifications
    debugPrint("🔔 NotificationService: Setting up Local Notifications...");
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Create the high importance channel for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
      debugPrint(
        "🔔 NotificationService: Android Notification Channel Created: ${channel.id}",
      );
    }

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint(
          "🔔 NotificationService: Notification Tap Payload: ${response.payload}",
        );
        if (response.payload != null) {
          _handleNavigation(response.payload!);
        }
      },
    );

    // 3. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("🔔 NotificationService: Foreground message received!");
      debugPrint(
        "🔔 NotificationService: Title: ${message.notification?.title}",
      );
      debugPrint("🔔 NotificationService: Body: ${message.notification?.body}");
      debugPrint("🔔 NotificationService: Data: ${message.data}");
      _showLocalNotification(message);
    });

    // 4. Handle Notification Clicks (Background State)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        "🔔 NotificationService: Notification clicked while in background",
      );
      if (message.data['actionUrl'] != null) {
        _handleNavigation(message.data['actionUrl']);
      }
    });

    // 5. Handle Initial Message (Terminated State)
    try {
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint(
          "🔔 NotificationService: App launched from terminated state via notification",
        );
        if (initialMessage.data['actionUrl'] != null) {
          _handleNavigation(initialMessage.data['actionUrl']);
        }
      }
    } catch (e) {
      debugPrint("🔔 NotificationService: Error getting initial message: $e");
    }

    // 6. Token Management
    _fcm.onTokenRefresh.listen((token) {
      debugPrint("🔔 NotificationService: FCM Token Refreshed: $token");
      if (AuthController.isLoggedIn) {
        _sendTokenToBackend(token);
      }
    });

    _isInitialized = true;
    debugPrint("🔔 NotificationService: Initialization Complete ✅");

    // Sync token if logged in
    await getTokenAndSendToBackend();
  }

  Future<void> getTokenAndSendToBackend() async {
    debugPrint("🔔 NotificationService: Starting token sync check...");
    if (!AuthController.isLoggedIn) {
      debugPrint(
        "🔔 NotificationService: Token sync skipped: User is NOT logged in.",
      );
      return;
    }

    try {
      debugPrint("🔔 NotificationService: Fetching FCM token from Firebase...");
      String? token = await _fcm.getToken();
      if (token != null) {
        debugPrint("🔔 NotificationService: FCM TOKEN RECEIVED: $token");
        await _sendTokenToBackend(token);
      } else {
        debugPrint("🔔 NotificationService: FCM Token is NULL - cannot sync.");
      }
    } catch (e) {
      debugPrint("🔔 NotificationService: ERROR fetching FCM token: $e");
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      debugPrint("🔔 NotificationService: Syncing deviceToken with backend...");
      debugPrint(
        "🔔 NotificationService: Target URL: ${Urls.updateUserProfile}",
      );

      final NetworkResponse response = await NetworkCaller.patchRequest(
        url: Urls.updateUserProfile,
        body: {'deviceToken': token},
        requireAuth: true,
      );

      if (response.isSuccess) {
        debugPrint(
          "🔔 NotificationService: ✅ Device token successfully synced with backend.",
        );
      } else {
        debugPrint(
          "🔔 NotificationService: ❌ Backend sync failed: ${response.errorMessage}",
        );
      }
    } catch (e) {
      debugPrint("🔔 NotificationService: ❌ CRITICAL ERROR syncing token: $e");
    }
  }

  void _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: message.data['actionUrl'],
      );
    }
  }

  void _handleNavigation(String actionUrl) {
    if (actionUrl.isEmpty) return;
    debugPrint("Navigating to: $actionUrl");

    // Use global navigatorKey for navigation
    // Ensure the actionUrl matches a route name or handle it dynamically
    navigatorKey.currentState?.pushNamed(actionUrl);
  }

  // Expose the background handler for registration in main()
  static Future<void> Function(RemoteMessage) get backgroundHandler =>
      _firebaseMessagingBackgroundHandler;
}
