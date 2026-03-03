import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends ChangeNotifier {
  static String? accessToken;
  static const String _tokenKey = 'user_token';

  /// Initialize AuthController and load token from storage
  static Future<void> initialize() async {
    accessToken = GetStorage().read(_tokenKey);
  }

  /// Save token to storage and update static variable
  static Future<void> saveUserToken(String token) async {
    await GetStorage().write(_tokenKey, token);
    accessToken = token;
  }

  /// Check if user is logged in
  static bool get isLoggedIn => accessToken != null;

  /// Logout and clear all auth related data
  Future<void> logoutAndClear() async {
    await GetStorage().remove(_tokenKey);
    accessToken = null;
    notifyListeners();
  }
}
