import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';

class LogOutController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;

  //getter
  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  //log out api call 


  Future<bool> logOut(String password)async{
    bool isSuccess =false;
    _inProgress = true;
    notifyListeners();

    Map<String,dynamic> requestBody = {
      "password" : password,
    };

    NetworkResponse response =await NetworkCaller.postRequest(url: Urls.logOut,body: requestBody);
    _inProgress = false;
    if(response.isSuccess){
      isSuccess = true;
    }else{
      _errorMessage = response.errorMessage;
    }
    notifyListeners();
    return isSuccess;
  }
}
