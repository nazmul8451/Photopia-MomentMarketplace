import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';

class ForgotPassController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;

  //getter
  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  Future<bool> forgotPassword(String email) async {
    bool isSuccess = false;
    _inProgress = true;
    notifyListeners();
    Map<String, dynamic> requestBody = {"email": email};

    NetworkResponse response = await NetworkCaller.postRequest(
      url: Urls.forgotPassword,
      body: requestBody,
      requireAuth: false,
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
