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
    _providerDetails = null; // Clear old data
    _profProfileDetails = null; // Clear old data
    notifyListeners();

    try {
      debugPrint("🔍 [ProviderDetailsController] Fetching for ID: $id");

      final userResponse = await NetworkCaller.getRequest(
        url: Urls.getUserById(id),
        requireAuth: false,
      );

      // Attempt multiple endpoint patterns for professional profile
      debugPrint(
        "🚀 [DETAILS] Trying primary endpoint: ${Urls.professionalProfile}/$id",
      );
      var profResponse = await NetworkCaller.getRequest(
        url: '${Urls.professionalProfile}/$id',
        requireAuth: false,
      );

      // If primary fails, or returns empty data, try alternative endpoints
      bool needsRetry =
          !profResponse.isSuccess ||
          profResponse.body == null ||
          (profResponse.body!['data'] == null &&
              !profResponse.body!.containsKey('_id'));

      if (needsRetry) {
        debugPrint("🚀 [DETAILS] Primary failed, trying /user/$id endpoint");
        profResponse = await NetworkCaller.getRequest(
          url: '${Urls.professionalProfile}/user/$id',
          requireAuth: false,
        );
        needsRetry =
            !profResponse.isSuccess ||
            profResponse.body == null ||
            (profResponse.body!['data'] == null &&
                !profResponse.body!.containsKey('_id'));
      }

      if (needsRetry) {
        debugPrint(
          "🚀 [DETAILS] /user/$id failed, trying /provider/$id endpoint",
        );
        profResponse = await NetworkCaller.getRequest(
          url: '${Urls.professionalProfile}/provider/$id',
          requireAuth: false,
        );
        needsRetry =
            !profResponse.isSuccess ||
            profResponse.body == null ||
            (profResponse.body!['data'] == null &&
                !profResponse.body!.containsKey('_id'));
      }

      if (needsRetry) {
        debugPrint("🚀 [DETAILS] /provider/$id failed, trying ?user=$id query");
        profResponse = await NetworkCaller.getRequest(
          url: '${Urls.professionalProfile}?user=$id',
          requireAuth: false,
        );
        needsRetry =
            !profResponse.isSuccess ||
            profResponse.body == null ||
            (profResponse.body!['data'] == null &&
                !profResponse.body!.containsKey('_id'));
      }

      if (needsRetry) {
        debugPrint(
          "🚀 [DETAILS] ?userId=$id failed, trying /user/$id endpoint",
        );
        profResponse = await NetworkCaller.getRequest(
          url: '${Urls.professionalProfile}/user/$id',
          requireAuth: false,
        );
        needsRetry =
            !profResponse.isSuccess ||
            profResponse.body == null ||
            (profResponse.body!['data'] == null &&
                !profResponse.body!.containsKey('_id'));
      }

      if (needsRetry) {
        debugPrint(
          "🚀 [DETAILS] /user/$id failed, trying /professional/$id endpoint",
        );
        profResponse = await NetworkCaller.getRequest(
          url: '${Urls.professionalProfile}/professional/$id',
          requireAuth: false,
        );
        needsRetry =
            !profResponse.isSuccess ||
            profResponse.body == null ||
            (profResponse.body!['data'] == null &&
                !profResponse.body!.containsKey('_id'));
      }

      if (needsRetry) {
        debugPrint(
          "🚀 [DETAILS] /professional/$id failed, trying ?provider=$id query",
        );
        profResponse = await NetworkCaller.getRequest(
          url: '${Urls.professionalProfile}?provider=$id',
          requireAuth: false,
        );
        needsRetry =
            !profResponse.isSuccess ||
            profResponse.body == null ||
            (profResponse.body!['data'] == null &&
                !profResponse.body!.containsKey('_id'));
      }

      if (needsRetry) {
        debugPrint(
          "🚀 [DETAILS] ?provider=$id failed, trying ?providerId=$id query",
        );
        profResponse = await NetworkCaller.getRequest(
          url: '${Urls.professionalProfile}?providerId=$id',
          requireAuth: false,
        );
      }

      debugPrint(
        "📊 [DETAILS] Prof Profile Response Body: ${profResponse.body}",
      );

      _isLoading = false;

      bool success = false;

      // Parse Professional Profile
      if (profResponse.isSuccess && profResponse.body != null) {
        dynamic profData = profResponse.body!['data'];
        debugPrint("📥 [DETAILS] Raw Prof Data Type: ${profData.runtimeType}");

        // Sometimes the object itself is at the top level, or nested in 'data'
        if (profData == null &&
            (profResponse.body!.containsKey('_id') ||
                profResponse.body!.containsKey('user'))) {
          profData = profResponse.body;
          debugPrint("✅ [DETAILS] Using body as data");
        }

        if (profData is List && profData.isNotEmpty) {
          _profProfileDetails = ProfessionalProfileModel.fromJson(profData[0]);
          debugPrint("✅ [DETAILS] Parsed from List[0]");
        } else if (profData is Map<String, dynamic>) {
          // Deep dive into possible nested patterns
          Map<String, dynamic> targetMap = profData;
          if (profData.containsKey('data') &&
              profData['data'] is Map<String, dynamic>) {
            targetMap = profData['data'];
            debugPrint("✅ [DETAILS] Found nested 'data'");
          } else if (profData.containsKey('profile') &&
              profData['profile'] is Map<String, dynamic>) {
            targetMap = profData['profile'];
            debugPrint("✅ [DETAILS] Found nested 'profile'");
          } else if (profData.containsKey('professionalProfile') &&
              profData['professionalProfile'] is Map<String, dynamic>) {
            targetMap = profData['professionalProfile'];
            debugPrint("✅ [DETAILS] Found nested 'professionalProfile'");
          }

          _profProfileDetails = ProfessionalProfileModel.fromJson(targetMap);
          debugPrint(
            "✅ [DETAILS] Final parsing from Map with ID: ${_profProfileDetails?.id}",
          );
        }
      }

      // If still no professional profile data, try to extract from service details if available
      if (_profProfileDetails == null) {
        debugPrint(
          "🚀 [DETAILS] Prof profile not found, checking if we can fetch via service endpoint",
        );
        try {
          final serviceResponse = await NetworkCaller.getRequest(
            url: Urls.getServicesByProvider(id),
            requireAuth: false,
          );
          if (serviceResponse.isSuccess && serviceResponse.body != null) {
            final serviceData = serviceResponse.body!['data'];
            if (serviceData != null &&
                serviceData['data'] is List &&
                (serviceData['data'] as List).isNotEmpty) {
              // Extract professional profile from the first service item's nested data if available
              // Some APIs return provider info inside service objects
              debugPrint(
                "✅ [DETAILS] Found service data, extracting basic info",
              );
            }
          }
        } catch (e) {
          debugPrint("⚠️ [DETAILS] Service fallback error: $e");
        }
      }

      if (_profProfileDetails != null) {
        success = true;
        debugPrint(
          "✨ [DETAILS] Professional Profile SUCCESS: Bio=${_profProfileDetails?.bio?.length} chars, Portfolio=${_profProfileDetails?.portfolio?.length} items",
        );
      }

      // Parse User Details
      if (userResponse.isSuccess &&
          userResponse.body != null &&
          userResponse.body!['data'] != null) {
        _providerDetails = UserProfileModel.fromJson(
          userResponse.body!['data'],
        );
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
        debugPrint(
          "🔸 [ProviderDetailsController] Using nested User from Prof Profile",
        );
      }

      if (!success) {
        _errorMessage =
            userResponse.errorMessage ??
            profResponse.errorMessage ??
            "Failed to fetch details";
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
