import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends ChangeNotifier {
  static const String _tokenKey = 'access_token';
  static const String _userRoleKey = 'user_role';

  static String? _accessToken;
  static final _secureStorage = const FlutterSecureStorage();
  static final _getStorage = GetStorage();

  static String? get accessToken => _accessToken;

  // Initialize and check auth state
  static Future<void> initialize() async {
    _accessToken = await _secureStorage.read(key: _tokenKey);
  }

  // Save token and session data
  static Future<void> saveUserToken(String token) async {
    _accessToken = token;
    await _secureStorage.write(key: _tokenKey, value: token);
    await _getStorage.write('user_token', token);
  }

  // Instance method for reactive UI checks
  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;

  // Save user role
  static Future<void> saveUserRole(String role) async {
    await _getStorage.write(_userRoleKey, role);
  }

  // Get user role
  static String? getUserRole() {
    return _getStorage.read(_userRoleKey);
  }

  // Clear all auth data (Logout)
  static Future<void> clearAuthData() async {
    _accessToken = null;
    await _secureStorage.delete(key: _tokenKey);
    await _getStorage.remove(_tokenKey);
    await _getStorage.remove('user_token');
    await _getStorage.remove(_userRoleKey);
  }

  // Instance method to trigger clear and notify listeners
  Future<void> logoutAndClear() async {
    await clearAuthData();
    notifyListeners();
  }
}
