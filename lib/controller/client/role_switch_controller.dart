import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';

class RoleSwitchController extends ChangeNotifier {
  bool _inProgress = false;
  bool get inProgress => _inProgress;

  Future<bool> switchRole(String targetRole) async {
    _inProgress = true;
    notifyListeners();
    try {
      final response = await NetworkCaller.patchRequest(
        url: Urls.role,
        body: {"role": targetRole},
      );

      _inProgress = false;
      notifyListeners();

      if (response.isSuccess) {
        return true;
      } else {
        debugPrint("RoleSwitchController Error: ${response.errorMessage}");
        return false;
      }
    } catch (e) {
      _inProgress = false;
      notifyListeners();
      debugPrint("RoleSwitchController Exception: $e");
      return false;
    }
  }
}
