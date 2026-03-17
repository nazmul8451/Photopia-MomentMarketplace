import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:photopia/core/routes/app_routes.dart';

/// A global navigator key used for navigation outside of widget context (e.g., from NetworkCaller)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthController extends ChangeNotifier {
  static String? accessToken;
  static String? activeRole;
  static String? refreshTokenCookie; // stores the raw Set-Cookie header value

  static const String _tokenKey = 'user_token';
  static const String _roleKey = 'active_role';
  static const String _cookieKey = 'refresh_cookie';

  /// Initialize AuthController and load token, role, and cookie from storage
  static Future<void> initialize() async {
    accessToken = GetStorage().read(_tokenKey);
    activeRole = GetStorage().read(_roleKey);
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
    notifyListeners();
  }

  /// Force logout when access token expires (called from NetworkCaller on 401)
  static Future<void> forceLogout() async {
    await GetStorage().remove(_tokenKey);
    await GetStorage().remove(_roleKey);
    accessToken = null;
    activeRole = null;
    debugPrint('🔐 Token expired. Forcing logout...');
    // Navigate to the sign-in screen globally
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.log_in,
      (route) => false,
    );
  }
}
