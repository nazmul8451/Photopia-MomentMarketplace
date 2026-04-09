import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

import 'package:photopia/controller/provider/wallet_controller.dart';
import 'package:photopia/controller/provider/provider_profile_controller.dart';
import 'package:photopia/controller/client/user_profile_controller.dart';
import 'package:photopia/controller/provider/statistics_controller.dart';
import 'package:photopia/controller/provider/service_controller.dart';
import 'package:photopia/controller/provider/my_listing_controller.dart';
import 'package:photopia/controller/provider/provider_orders_controller.dart';
import 'package:photopia/controller/provider/subscription_controller.dart';
import 'package:photopia/controller/provider/calender_availibility_controller.dart';
import 'package:photopia/controller/client/chat_controller.dart';
import 'package:photopia/controller/client/notification_controller.dart';
import 'package:photopia/core/routes/app_routes.dart';

/// A global navigator key used for navigation outside of widget context (e.g., from NetworkCaller)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthController extends ChangeNotifier {
  static String? accessToken;
  static String? activeRole;
  static String? userId;
  static String? refreshTokenCookie; // stores the raw Set-Cookie header value

  static const String _tokenKey = 'user_token';
  static const String _roleKey = 'active_role';
  static const String _userIdKey = 'user_id';
  static const String _cookieKey = 'refresh_cookie';

  /// Initialize AuthController and load token, role, and cookie from storage
  static Future<void> initialize() async {
    accessToken = GetStorage().read(_tokenKey);
    activeRole = GetStorage().read(_roleKey);
    userId = GetStorage().read(_userIdKey);
    refreshTokenCookie = GetStorage().read(_cookieKey);
  }

  /// Save token to storage and update static variable
  static Future<void> saveUserToken(String token) async {
    await GetStorage().write(_tokenKey, token);
    accessToken = token;
  }

  /// Save role to storage and update static variable
  static Future<void> saveUserRole(String role) async {
    await GetStorage().write(_roleKey, role);
    activeRole = role;
  }

  /// Save userId to storage and update static variable
  static Future<void> saveUserId(String id) async {
    await GetStorage().write(_userIdKey, id);
    userId = id;
  }

  /// Save the raw Set-Cookie header from the login response
  static Future<void> saveRefreshCookie(String cookie) async {
    await GetStorage().write(_cookieKey, cookie);
    refreshTokenCookie = cookie;
  }

  /// Check if user is logged in
  static bool get isLoggedIn => accessToken != null;

  /// Logout and clear all auth related data
  Future<void> logoutAndClear() async {
    await GetStorage().remove(_tokenKey);
    await GetStorage().remove(_roleKey);
    accessToken = null;
    activeRole = null;
    userId = null;
    notifyListeners();
  }

  static bool _isLoggingOut = false;

  /// Force logout when access token expires (called from NetworkCaller on 401)
  static Future<void> forceLogout([BuildContext? context]) async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      // 1. Reset all controllers if context is provided or can be found
      final BuildContext? activeContext = context ?? navigatorKey.currentContext;
      if (activeContext != null) {
        try {
          // Provider Controllers
          activeContext.read<WalletController>().reset();
          activeContext.read<ProviderProfileController>().reset();
          activeContext.read<UserProfileController>().reset();
          activeContext.read<StatisticsController>().reset();
          activeContext.read<ServiceController>().reset();
          activeContext.read<MyListingController>().reset();
          activeContext.read<ProviderOrdersController>().reset();
          activeContext.read<SubscriptionController>().reset();
          activeContext.read<CalenderAvailibilityController>().reset();
          
          // Client Controllers (Need to ensure they have reset handlers if used, 
          // but we know Notification and Chat do now)
          activeContext.read<NotificationController>().reset();
          activeContext.read<ChatController>().reset();
          
          debugPrint('🧹 All controllers reset successfully.');
        } catch (e) {
          debugPrint('⚠️ Error resetting controllers: $e');
        }
      }

      await GetStorage().remove(_tokenKey);
      await GetStorage().remove(_roleKey);
      await GetStorage().remove(_userIdKey);
      accessToken = null;
      activeRole = null;
      userId = null;
      debugPrint('🔐 Token expired. Forcing logout...');
      
      // Navigate to the sign-in screen globally using the navigatorKey
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.log_in,
        (route) => false,
      );
    } finally {
      // Reset after a delay to allow the navigation to complete 
      // and avoid immediate re-triggering if some cleanup logic runs.
      Future.delayed(const Duration(seconds: 2), () {
        _isLoggingOut = false;
      });
    }
  }
}
