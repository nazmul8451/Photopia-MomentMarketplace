import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends ChangeNotifier {
  static String? accessToken;
  static String? activeRole;

  static const String _tokenKey = 'user_token';
  static const String _roleKey = 'active_role';

  /// Initialize AuthController and load token and role from storage
  static Future<void> initialize() async {
    accessToken = GetStorage().read(_tokenKey);
    activeRole = GetStorage().read(_roleKey);
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
}
