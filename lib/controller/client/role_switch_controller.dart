import 'package:flutter/material.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';

class RoleSwitchController extends ChangeNotifier {
  bool _inProgress = false;
  bool get inProgress => _inProgress;

  Future<bool> switchRole(
    String targetRole, {
    List<String>? specialties,
  }) async {
    _inProgress = true;
    notifyListeners();
    try {
      // 1. Switch Role
      final Map<String, dynamic> body = {"role": targetRole};
      final response = await NetworkCaller.patchRequest(
        url: Urls.role,
        body: body,
      );

      if (response.isSuccess) {
        await AuthController.saveUserRole(targetRole);

        // 2. If professional and have specialties, update professional profile
        if (targetRole == 'professional' &&
            specialties != null &&
            specialties.isNotEmpty) {
          debugPrint(
            '👔 Updating specialties in professional profile: $specialties',
          );
          await NetworkCaller.patchRequest(
            url: Urls.professionalProfile,
            body: {"specialties": specialties},
          );
        }

        _inProgress = false;
        notifyListeners();
        return true;
      } else {
        debugPrint("RoleSwitchController Error: ${response.errorMessage}");
        _inProgress = false;
        notifyListeners();
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
