import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/user_profile_model.dart';

class ProviderProfileController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;
  UserProfileModel? _userProfile;

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;
  UserProfileModel? get userProfile => _userProfile;

  // Convenience getters for easier UI binding
  String get name => _userProfile?.fullName ?? 'Michael Photographer';
  String get aboutMe =>
      _userProfile?.description ??
      'Professional wedding and event photographer with 10+ years of experience. Specialized in capturing authentic moments and emotions.';
  String get specialty =>
      _userProfile?.specialty ?? 'Professional Photographer';
  String? get profileImage => _userProfile?.profile;

  List<String> _specializations = ['Wedding', 'Event', 'Portrait'];
  List<String> _languages = ['English', 'Spanish', 'Catalan'];
  List<String> _recentWork = [
    'assets/images/img1.png',
    'assets/images/img2.png',
    'assets/images/img3.png',
    'assets/images/img4.png',
    'assets/images/img5.png',
    'assets/images/img6.png',
  ];

  List<String> get specializations => _specializations;
  List<String> get languages => _languages;
  List<String> get recentWork => _recentWork;

  Future<bool> getProviderProfile() async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    final response = await NetworkCaller.getRequest(url: Urls.userProfile);

    _inProgress = false;
    if (response.isSuccess) {
      final data = response.body?['data'];
      if (data != null) {
        _userProfile = UserProfileModel.fromJson(data);
      }
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProviderProfile({
    String? name,
    String? description,
    String? specialty,
  }) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (specialty != null) body['specialty'] = specialty;

      final response = await NetworkCaller.patchRequest(
        url: Urls.updateUserProfile,
        body: body,
      );

      debugPrint(
        'Update Profile Response: ${response.statusCode} - ${response.isSuccess}',
      );

      if (response.isSuccess) {
        // The API returns a string "Profile updated successfully." instead of the user object
        // So we just fetch the profile again to get updated data
        await getProviderProfile();
        return true;
      } else {
        _errorMessage = response.errorMessage;
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _errorMessage = 'An unexpected error occurred';
      return false;
    } finally {
      _inProgress = false;
      notifyListeners();
    }
  }

  void updateProfile({
    String? name,
    String? aboutMe,
    List<String>? specializations,
    List<String>? languages,
    List<String>? recentWork,
  }) {
    // This could be updated to call an API in the future
    notifyListeners();
  }

  void addSpecialization(String spec) {
    if (!_specializations.contains(spec)) {
      _specializations.add(spec);
      notifyListeners();
    }
  }

  void removeSpecialization(String spec) {
    _specializations.remove(spec);
    notifyListeners();
  }

  void addLanguage(String lang) {
    if (!_languages.contains(lang)) {
      _languages.add(lang);
      notifyListeners();
    }
  }

  void removeLanguage(String lang) {
    _languages.remove(lang);
    notifyListeners();
  }

  void addRecentWork(String url) {
    _recentWork.add(url);
    notifyListeners();
  }

  void removeRecentWork(String url) {
    _recentWork.remove(url);
    notifyListeners();
  }

  void reset() {
    _userProfile = null;
    _specializations = ['Wedding', 'Event', 'Portrait'];
    _languages = ['English', 'Spanish', 'Catalan'];
    _recentWork = [
      'assets/images/img1.png',
      'assets/images/img2.png',
      'assets/images/img3.png',
      'assets/images/img4.png',
      'assets/images/img5.png',
      'assets/images/img6.png',
    ];
    notifyListeners();
  }
}
