import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';

class BookingController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> createBooking({
    required String providerId,
    required String serviceId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    required String address,
    required String city,
    required String country,
    required double lat,
    required double lng,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    String? eventType,
    String? specialRequests,
    int distanceFromProviderKm = 0,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final Map<String, dynamic> body = {
      "providerId": providerId,
      "serviceId": serviceId,
      "bookingDate": bookingDate,
      "startTime": startTime,
      "endTime": endTime,
      "eventLocation": {
        "address": address,
        "city": city,
        "country": country,
        "coordinates": {
          "lat": lat,
          "lng": lng,
        },
        "distanceFromProviderKm": distanceFromProviderKm,
        "notes": notes ?? "",
      },
      "clientName": clientName ?? "",
      "clientEmail": clientEmail ?? "",
      "clientPhone": clientPhone ?? "",
      "eventType": eventType ?? "General",
      "specialRequests": specialRequests ?? "",
    };

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.createBooking,
        body: body,
      );

      if (response.isSuccess) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to create booking";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
