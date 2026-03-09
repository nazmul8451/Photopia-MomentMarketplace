import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/user_profile_model.dart';

class ProviderDetailsController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserProfileModel? _providerDetails;
  UserProfileModel? get providerDetails => _providerDetails;

  Future<bool> getProviderDetails(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // We use getRequest without requireAuth false if it's a public endpoint,
    // or true if it needs the token. Since the screenshot showed an admin token
    // being used, maybe requireAuth is needed. We'll set it to false for now
    // to test if it's accessible publicly like services, or true if it fails.
    // Actually, getting a user's public profile usually shouldn't require auth
    // in this context, but let's see. Let's use requireAuth: true to be safe,
    // or false if guest access is needed. The user screenshot showed Authorization token.
    final response = await NetworkCaller.getRequest(
      url: Urls.getUserById(id),
      requireAuth: true,
    );

    _isLoading = false;

    if (response.isSuccess && response.body != null) {
      try {
        final data = response.body!['data'];
        if (data != null) {
          _providerDetails = UserProfileModel.fromJson(data);
          notifyListeners();
          return true;
        } else {
          _errorMessage = "No data received";
        }
      } catch (e) {
        _errorMessage = "Error parsing provider details: $e";
        debugPrint("ProviderDetailsController parsing error: $e");
      }
    } else {
      _errorMessage =
          response.errorMessage ?? "Failed to fetch provider details";
    }

    notifyListeners();
    return false;
  }
}
