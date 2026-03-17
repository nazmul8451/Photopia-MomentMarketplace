import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/network/urls.dart';

class SignInController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;

  //getter
  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  //sign in api call
  Future<bool> signIn(String email, String password) async {
    bool isSuccess = false;
    _inProgress = true;
    notifyListeners();

    try {
      final uri = Uri.parse(Urls.signIn);
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      _inProgress = false;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final token = body['data']?['accessToken'];
        final role = body['data']?['user']?['activeRole'];

        if (token != null) {
          await AuthController.saveUserToken(token);
        }
        if (role != null) {
          await AuthController.saveUserRole(role);
        }

        // Capture the Set-Cookie header so we can use it for token refresh later
        final setCookie = response.headers['set-cookie'];
        if (setCookie != null && setCookie.isNotEmpty) {
          await AuthController.saveRefreshCookie(setCookie);
          debugPrint('🍪 Refresh cookie saved: $setCookie');
        }

        isSuccess = true;
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        _errorMessage = body['message'] ?? 'Sign in failed';
      }
    } catch (e) {
      _inProgress = false;
      _errorMessage = 'An unexpected error occurred: $e';
    }

    notifyListeners();
    return isSuccess;
  }
}
