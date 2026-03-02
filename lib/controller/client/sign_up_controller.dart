import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';

class SignUpController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;

  //getter
  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  //sign up api call

  Future<bool> signUp(String email, String name, String password) async {
    bool isSuccess = false;

    _inProgress = true;
    notifyListeners();

    Map<String, dynamic> requestBody = {
      "email": email,
      "name": name,
      "password": password,
    };
    NetworkResponse response = await NetworkCaller.postRequest(
      url: Urls.signUp,
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
