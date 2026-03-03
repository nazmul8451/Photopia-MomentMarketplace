import 'package:flutter/material.dart';

import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/user_profile_model.dart';

class UserProfileController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;
  UserProfileModel? _userProfile;

  // Getters
  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;
  UserProfileModel? get userProfile => _userProfile;

  Future<void> getUserProfile() async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    NetworkResponse response = await NetworkCaller.getRequest(
      url: Urls.userProfile,
      requireAuth: true,
    );

    if (response.isSuccess) {
      final data = response.body?['data'];
      if (data != null) {
        _userProfile = UserProfileModel.fromJson(data);
      }
    } else {
      _errorMessage = response.errorMessage;
    }

    _inProgress = false;
    notifyListeners();
  }
}
