import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';

class ResetPasswordController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  Future<bool> resetPassword(
    String email,
    String token,
    String password,
  ) async {
    bool isSuccess = false;
    _inProgress = true;
    notifyListeners();

    Map<String, dynamic> requestBody = {
      "email": email,
      "token": token,
      "newPassword": password,
      "confirmPassword": password,
    };

    NetworkResponse response = await NetworkCaller.postRequest(
      url: Urls.resetPassword,
      body: requestBody,
    );

    _inProgress = false;
    if (response.isSuccess) {
      isSuccess = true;
    } else {
      _errorMessage = response.errorMessage;
    }
    notifyListeners();
    return isSuccess;
  }
}
