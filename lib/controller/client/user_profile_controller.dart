import 'package:flutter/material.dart';

import 'package:photopia/controller/auth_controller.dart';
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
        if (_userProfile?.role != null) {
          await AuthController.saveUserRole(_userProfile!.role!);
        }
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
    String? email,
    String? description,
    String? specialty,
    String? imagePath,
  }) async {
    _isUpdateInProgress = true;
    _errorMessage = null;
    notifyListeners();

    NetworkResponse response;

    if (imagePath != null && imagePath.isNotEmpty) {
      debugPrint(
        "UserProfileController: Updating WITH image (Multipart). Path: $imagePath",
      );
      // Has image — use multipart form-data
      Map<String, String> fields = {};
      if (name != null) fields['name'] = name;
      if (phoneNumber != null) fields['phone'] = phoneNumber;
      if (email != null) fields['email'] = email;
      if (description != null) fields['description'] = description;
      if (specialty != null) fields['specialty'] = specialty;

      response = await NetworkCaller.multipartRequest(
        url: Urls.updateUserProfile,
        method: 'PATCH',
        fields: fields.isNotEmpty ? fields : null,
        fileKey: 'images',
        filePath: imagePath,
        requireAuth: true,
      );
    } else {
      debugPrint("UserProfileController: Updating WITHOUT image (JSON PATCH).");
      // No image — use plain JSON PATCH
      Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (phoneNumber != null) body['phone'] = phoneNumber;
      if (email != null) body['email'] = email;
      if (description != null) body['description'] = description;
      if (specialty != null) body['specialty'] = specialty;

      response = await NetworkCaller.patchRequest(
        url: Urls.updateUserProfile,
        body: body,
        requireAuth: true,
      );
    }

    _isUpdateInProgress = false;

    if (response.isSuccess) {
      await getUserProfile();
      return true;
    } else {
      _errorMessage = response.errorMessage;
      notifyListeners();
      return false;
    }
  }
}
