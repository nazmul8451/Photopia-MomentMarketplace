import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
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

    Map<String, String> requestBody = {"email": email, "password": password};
    NetworkResponse response = await NetworkCaller.postRequest(
      url: Urls.signIn,
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
