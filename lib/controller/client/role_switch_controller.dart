

import 'package:flutter/material.dart';
import 'package:http/http.dart' as ApiService;
import 'package:photopia/core/network/urls.dart';

class RoleSwitchController extends ChangeNotifier {
  bool _inProgress = false;
  bool get inProgress => _inProgress;

  Future<void> switchRole() async {
    _inProgress = true;
    notifyListeners();
    try {
      final response = await ApiService.patch(Urls.role);
      if (response['status'] == true) {
        _inProgress = false;
        notifyListeners();
      }
    } catch (e) {
      _inProgress = false;
      notifyListeners();
    }
  }
}