import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/calender_availibility_model.dart';

class CalenderAvailibilityController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  Future<bool> updateAvailability(Data availabilityData) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Convert Data object to JSON map
      final Map<String, dynamic> body = availabilityData.toJson();

      // Remove internal metadata that should not be sent
      body.remove('_id');
      body.remove('id');
      body.remove('createdAt');
      body.remove('updatedAt');
      body.remove('__v');
      
      // As per analysis.txt and Postman screenshot, serviceId is not present
      body.remove('serviceId');

      // Keep only non-null values
      body.removeWhere((key, value) => value == null);

      debugPrint(
        '🚀 Sending Availability Update to ${Urls.calenderSettings}',
      );
      debugPrint('📦 Body: ${jsonEncode(body)}');

      final NetworkResponse response = await NetworkCaller.postRequest(
        url: Urls.calenderSettings,
        body: body,
        requireAuth: true,
      );

      _inProgress = false;
      if (response.isSuccess) {
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            response.errorMessage ?? 'Failed to update availability';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _inProgress = false;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  Future<CalenderSettingsModel?> getAvailabilitySettings({String? providerId}) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String url = providerId != null 
          ? Urls.getProviderAvailability(providerId) 
          : Urls.calenderSettings;

      final NetworkResponse response = await NetworkCaller.getRequest(
        url: url,
        requireAuth: true,
      );

      _inProgress = false;
      if (response.isSuccess && response.body != null) {
        notifyListeners();
        return CalenderSettingsModel.fromJson(response.body!);
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to fetch availability';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _inProgress = false;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return null;
    }
  }
}
