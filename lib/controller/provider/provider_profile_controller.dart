import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:photopia/controller/auth_controller.dart';
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
  String get shortBio =>
      _professionalProfile?.bio ?? '';
  String get specialty =>
      _userProfile?.specialty ??
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

  List<String> get specializations => _professionalProfile?.specialties?.map((e) => e.toString()).toList() ?? [];
  List<String> get languages => _professionalProfile?.language?.map((e) => e.toString()).toList() ?? [];
  List<dynamic> get recentWork => _professionalProfile?.portfolio?.toList() ?? [];

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
    String? bio,
    String? description,
    String? specialty,
    List<String>? specializations,
    List<String>? languages,
    List<dynamic>? recentWork,
  }) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Update Professional Profile Data (Add/Update only)
      bool profProfileSuccess = true;
      if (bio != null || specializations != null || languages != null || recentWork != null) {
        
        final List<File> newFiles = [];
        if (recentWork != null) {
          for (var item in recentWork) {
            if (item is File) newFiles.add(item);
          }
        }

        debugPrint('👔 Updating Prof Profile (includes ${newFiles.length} new files)');
        String? token = AuthController.accessToken;
        final Uri uri = Uri.parse(Urls.professionalProfile);
        final request = http.MultipartRequest('PATCH', uri);

        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = token.startsWith('Bearer ') ? token : 'Bearer $token';
        }
        request.headers['Accept'] = 'application/json';

        // Add root-level fields (Cleanest for your backend)
        if (bio != null) request.fields['bio'] = bio;
        
        // Add array fields as repeated keys (Multer style)
        if (specializations != null) {
           for (var s in specializations) {
             request.fields['specialties[]'] = s;
           }
        }
        if (languages != null) {
           for (var l in languages) {
             request.fields['language[]'] = l;
           }
        }

        // Add ONLY new files to portfolio (to avoid duplication)
        if (newFiles.isNotEmpty) {
          for (var file in newFiles) {
            final fileStream = http.ByteStream(file.openRead());
            final length = await file.length();
            final multipartFile = http.MultipartFile(
              'portfolio',
              fileStream,
              length,
              filename: file.path.split('/').last,
              contentType: MediaType('image', 'jpeg'),
            );
            request.files.add(multipartFile);
          }
        }

        try {
          final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
          final response = await http.Response.fromStream(streamedResponse);
          debugPrint("👔 Prof Profile Update Status: ${response.statusCode}");
          debugPrint("👔 Prof Profile Update Body: ${response.body}");
          
          profProfileSuccess = (response.statusCode >= 200 && response.statusCode < 300);
          if (!profProfileSuccess) {
            try {
              _errorMessage = jsonDecode(response.body)['message'];
            } catch (_) {
              _errorMessage = "Failed to update professional profile.";
            }
          }
        } catch (e) {
          debugPrint('👔 Update failed: $e');
          _errorMessage = "Connection error during update.";
          profProfileSuccess = false;
        }
      }

      // 2. Update User Profile Data
      bool userProfileSuccess = true;
      if (description != null || name != null) {
        debugPrint('👔 Updating User Profile: name=$name, description=${description?.substring(0, 20)}...');
        final response = await NetworkCaller.patchRequest(
          url: Urls.updateUserProfile,
          body: {
            if (name != null) 'name': name,
            if (description != null) 'description': description,
          },
        );
        userProfileSuccess = response.isSuccess;
      }

      if (profProfileSuccess && userProfileSuccess) {
        await getProviderProfile();
        return true;
      } else {
        if (_errorMessage == null && !userProfileSuccess) _errorMessage = "Failed to update user profile.";
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _errorMessage = 'Crash: $e';
      return false;
    } finally {
      _inProgress = false;
      notifyListeners();
    }
  }

  /// Removes specific items from professional profile fields.
  Future<bool> removeItemFromProfessionalProfile({required String field, required String value}) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('👔 Removing item: field=$field, value=$value');
      final response = await NetworkCaller.patchRequest(
        url: Urls.removeProfProfileItems,
        body: {
          "field": field,
          "values": [value]
        },
      );

      if (response.isSuccess) {
        debugPrint('✅ Successfully removed item from $field');
        return true;
      } else {
        _errorMessage = "Failed to remove item: ${response.body?['message'] ?? 'Unknown error'}";
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error removing item: $e');
      _errorMessage = "Error connecting to server.";
      return false;
    } finally {
      _inProgress = false;
      notifyListeners();
    }
  }


  void reset() {
    _userProfile = null;
    _professionalProfile = null;
    notifyListeners();
  }
}
