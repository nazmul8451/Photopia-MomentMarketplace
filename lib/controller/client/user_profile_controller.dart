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

  bool _isUpdateInProgress = false;
  bool get isUpdateInProgress => _isUpdateInProgress;

  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? location,
    String? imagePath,
  }) async {
    _isUpdateInProgress = true;
    _errorMessage = null;
    notifyListeners();

    Map<String, String> fields = {};
    if (name != null) fields['name'] = name;
    if (phoneNumber != null) fields['phone'] = phoneNumber;
    if (location != null) fields['location'] = location;

    NetworkResponse response = await NetworkCaller.multipartRequest(
      url: Urls.updateUserProfile,
      method: 'PATCH',
      fields: fields.isNotEmpty ? fields : null,
      fileKey: 'images', // API expects 'images' as the multipart field key
      filePath: imagePath,
      requireAuth: true,
    );

    _isUpdateInProgress = false;

    if (response.isSuccess) {
      // Re-fetch user profile to update the UI with new data
      await getUserProfile();
      return true;
    } else {
      _errorMessage = response.errorMessage;
      notifyListeners();
      return false;
    }
  }
}
