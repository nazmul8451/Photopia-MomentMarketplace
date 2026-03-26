import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/user_profile_model.dart';
import 'package:photopia/data/models/professional_profile_model.dart';

class ProviderProfileController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;
  UserProfileModel? _userProfile;
  ProfessionalProfileModel? _professionalProfile;
  
  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;
  UserProfileModel? get userProfile => _userProfile;
  ProfessionalProfileModel? get professionalProfile => _professionalProfile;

  String get name =>
      _professionalProfile?.user?.name ?? _userProfile?.fullName ?? 'Michael Photographer';
  String get aboutMe =>
      _professionalProfile?.user?.description ??
      _userProfile?.description ??
      'Professional wedding and event photographer with 10+ years of experience.';
  String get specialty =>
      _userProfile?.specialty ??
      _professionalProfile?.user?.description ??
      'Professional Photographer';
  String? get profileImage =>
      _professionalProfile?.user?.profile ?? _userProfile?.profile;

  // Stats getters
  int get bookingsCount => _professionalProfile?.statistics?.bookings?.count ?? 0;
  int get bookingsThisWeek => _professionalProfile?.statistics?.bookings?.thisWeek ?? 0;
  double get revenueAmount => (_professionalProfile?.statistics?.revenue?.amount ?? 0).toDouble();
  int get revenueChange => _professionalProfile?.statistics?.revenue?.percentageChange ?? 0;
  int get profileViews => _professionalProfile?.profileViews ?? 0;
  double get rating => _professionalProfile?.rating ?? 0.0;
  int get reviewCount => _professionalProfile?.reviewCount ?? 0;
  int get projectsCount => _professionalProfile?.projects ?? 0;
  int get responseRate => _professionalProfile?.responseRate ?? 0;

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

    // Fetch both user profile and professional profile statistics
    final userProfileResponse = await NetworkCaller.getRequest(url: Urls.userProfile);
    final professionalProfileResponse = await NetworkCaller.getRequest(url: Urls.professionalProfile);

    debugPrint("🔍 User Profile Response: ${userProfileResponse.isSuccess} - ${userProfileResponse.body}");
    debugPrint("🔍 Prof Profile Response: ${professionalProfileResponse.isSuccess} - ${professionalProfileResponse.body}");

    _inProgress = false;
    
    if (userProfileResponse.isSuccess) {
      final data = userProfileResponse.body?['data'];
      if (data != null) {
        _userProfile = UserProfileModel.fromJson(data);
      }
    }

    if (professionalProfileResponse.isSuccess) {
      final data = professionalProfileResponse.body?['data'];
      if (data != null) {
        _professionalProfile = ProfessionalProfileModel.fromJson(data);
        debugPrint("✅ Parsed Prof Profile: Bookings=${_professionalProfile?.statistics?.bookings?.count}, ThisWeek=${_professionalProfile?.statistics?.bookings?.thisWeek}");
      }
    }

    notifyListeners();
    return userProfileResponse.isSuccess || professionalProfileResponse.isSuccess;
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
