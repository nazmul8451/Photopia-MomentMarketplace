import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/professional_profile_model.dart';
import 'package:photopia/data/models/user_profile_model.dart';

class ProviderDetailsController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserProfileModel? _providerDetails;
  UserProfileModel? get providerDetails => _providerDetails;

  ProfessionalProfileModel? _profProfileDetails;
  ProfessionalProfileModel? get profProfileDetails => _profProfileDetails;

  Future<bool> getProviderDetails(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint("🔍 [ProviderDetailsController] Fetching for ID: $id");
      
      final userResponse = await NetworkCaller.getRequest(url: Urls.getUserById(id), requireAuth: true);
      
      // Attempt multiple endpoint patterns for professional profile
      debugPrint("🚀 [DETAILS] Trying primary endpoint: ${Urls.professionalProfile}/$id");
      var profResponse = await NetworkCaller.getRequest(url: '${Urls.professionalProfile}/$id', requireAuth: true);
      
      if (!profResponse.isSuccess || profResponse.body?['data'] == null) {
        debugPrint("🚀 [DETAILS] Primary failed, trying /user/$id endpoint");
        profResponse = await NetworkCaller.getRequest(url: '${Urls.professionalProfile}/user/$id', requireAuth: true);
      }
      
      if (!profResponse.isSuccess || profResponse.body?['data'] == null) {
        debugPrint("🚀 [DETAILS] /user/$id failed, trying ?user=$id query");
        profResponse = await NetworkCaller.getRequest(url: '${Urls.professionalProfile}?user=$id', requireAuth: true);
      }
      
      if (!profResponse.isSuccess || profResponse.body?['data'] == null) {
        debugPrint("🚀 [DETAILS] ?user=$id failed, trying ?userId=$id query");
        profResponse = await NetworkCaller.getRequest(url: '${Urls.professionalProfile}?userId=$id', requireAuth: true);
      }

      debugPrint("📊 [DETAILS] Prof Profile Response Body: ${profResponse.body}");

      _isLoading = false;

      bool success = false;

      // Parse Professional Profile
      if (profResponse.isSuccess && profResponse.body != null && profResponse.body!['data'] != null) {
        final profData = profResponse.body!['data'];
        debugPrint("📥 [DETAILS] Raw Prof Data Type: ${profData.runtimeType}");
        
        if (profData is List && profData.isNotEmpty) {
          _profProfileDetails = ProfessionalProfileModel.fromJson(profData[0]);
          debugPrint("✅ [DETAILS] Parsed from List[0]");
        } else if (profData is Map<String, dynamic>) {
          // Check if data is nested inside 'data' or is the direct object
          if (profData.containsKey('data') && profData['data'] is Map<String, dynamic>) {
            _profProfileDetails = ProfessionalProfileModel.fromJson(profData['data']);
            debugPrint("✅ [DETAILS] Parsed from nested Map['data']");
          } else {
            _profProfileDetails = ProfessionalProfileModel.fromJson(profData);
            debugPrint("✅ [DETAILS] Parsed from direct Map");
          }
        } else {
           debugPrint("⚠️ [DETAILS] Prof Data is neither List nor Map: $profData");
        }
        success = true;
      } else {
        debugPrint("❌ [DETAILS] No Prof Profile data found for ID: $id");
      }

      // Parse User Details
      if (userResponse.isSuccess && userResponse.body != null && userResponse.body!['data'] != null) {
        _providerDetails = UserProfileModel.fromJson(userResponse.body!['data']);
        success = true;
        debugPrint("✅ [ProviderDetailsController] User Details Success");
      } 
      // Fallback: If prof profile has user nested, use it
      else if (_profProfileDetails?.user != null) {
        // Create a basic UserProfileModel from the professional profile's user object
        final u = _profProfileDetails!.user!;
        _providerDetails = UserProfileModel(
          id: u.id,
          fullName: u.name,
          email: u.email,
          profile: u.profile,
          description: u.description,
        );
        success = true;
        debugPrint("🔸 [ProviderDetailsController] Using nested User from Prof Profile");
      }

      if (!success) {
        _errorMessage = userResponse.errorMessage ?? profResponse.errorMessage ?? "Failed to fetch details";
      }
      
      notifyListeners();
      return success;
      
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Exception: $e";
      debugPrint("❌ [ProviderDetailsController] Crash: $e");
    }

    notifyListeners();
    return false;
  }
}
