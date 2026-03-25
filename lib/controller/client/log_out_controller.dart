import 'package:flutter/material.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';

class LogOutController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;

  //getter
  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  //log out api call 


  //log out api call 
  Future<bool> logOut({String? password}) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('📡 Attempting API logout...');
      
      // Send an empty map if no password is provided
      Map<String, dynamic> requestBody = {};
      if (password != null && password.isNotEmpty) {
        requestBody = {"password": password};
      }

      NetworkResponse response = await NetworkCaller.postRequest(
        url: Urls.logOut,
        body: requestBody,
        cookie: AuthController.refreshTokenCookie,
      );

      _inProgress = false;
      if (response.isSuccess) {
        debugPrint('✅ API logout successful.');
        notifyListeners();
        return true;
      } else if (response.statusCode == 403) {
        // 403 is a backend role restriction, but we've handled logout locally.
        debugPrint('ℹ️ 403 Forbidden: Bypassing to local logout.');
        notifyListeners();
        return true;
      } else {
        debugPrint('⚠️ API logout failed: ${response.statusCode}');
        _errorMessage = response.errorMessage;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('🔴 API logout error: $e');
      _inProgress = false;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }
}
