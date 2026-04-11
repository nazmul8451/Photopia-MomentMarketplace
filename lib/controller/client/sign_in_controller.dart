import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/core/notification/notification_service.dart';

class SignInController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;

  //getter
  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  //sign in api call
  Future<bool> signIn(String email, String password) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final NetworkResponse response = await NetworkCaller.postRequest(
        url: Urls.signIn,
        body: {"email": email, "password": password},
        requireAuth: false, // Login is public
      );

      _inProgress = false;

      if (response.isSuccess && response.body != null) {
        final body = response.body!;
        final token = body['data']?['accessToken'];
        final role = body['data']?['user']?['activeRole'];
        final userId =
            body['data']?['user']?['_id'] ??
            body['data']?['user']?['id'] ??
            body['data']?['user']?['userId'] ??
            body['data']?['_id'] ??
            body['data']?['id'] ??
            body['data']?['userId'];

        if (token != null) {
          await AuthController.saveUserToken(token);
        }
        if (role != null) {
          await AuthController.saveUserRole(role);
        }
        if (userId != null) {
          await AuthController.saveUserId(userId);
        }

        // Trigger push notification token sync after login
        // Use post-frame callback to ensure any state updates from login have settled
        WidgetsBinding.instance.addPostFrameCallback((_) {
          NotificationService.instance.getTokenAndSendToBackend();
        });

        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? 'Sign in failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _inProgress = false;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }
}
