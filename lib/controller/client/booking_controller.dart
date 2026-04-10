import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/booking_model.dart';

class BookingController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? _lastBookingId;
  String? get lastBookingId => _lastBookingId;

  List<Booking> _bookings = [];
  List<Booking> get bookings => _bookings;

  Future<bool> getMyBookings({String? status, String? filterType}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String url = Urls.getMyOrders(
        status: status,
        filterType: filterType,
      );
      final response = await NetworkCaller.getRequest(
        url: url,
        requireAuth: true,
      );

      _isLoading = false;
      if (response.isSuccess && response.body != null) {
        final model = BookingModel.fromJson(response.body!);
        _bookings = model.data ?? [];
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to fetch bookings";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Error fetching bookings: $e";
      notifyListeners();
      return false;
    }
  }

  Future<String?> createBooking({
    required String providerId,
    required String serviceId,
    required String bookingDate,
    required String startTime,
    String? endTime,
    String? packageName,
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
    double distanceFromProviderKm = 0,
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
      "eventLocation": {
        "address": address,
        "city": city,
        "country": country,
        "coordinates": {"lat": lat, "lng": lng},
        "distanceFromProviderKm": distanceFromProviderKm,
      },
      "clientName": clientName ?? "",
      "clientEmail": clientEmail ?? "",
      "clientPhone": clientPhone ?? "",
    };

    if (endTime != null && endTime.isNotEmpty) {
      body["endTime"] = endTime;
    }

    if (packageName != null && packageName.isNotEmpty) {
      body["packageName"] = packageName;
    }

    if (notes != null && notes.isNotEmpty) {
      body["eventLocation"]["notes"] = notes;
    }

    if (eventType != null && eventType.isNotEmpty) {
      body["eventType"] = eventType;
    }

    if (specialRequests != null && specialRequests.isNotEmpty) {
      body["specialRequests"] = specialRequests;
    }

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.createBooking,
        body: body,
      );

      if (response.isSuccess) {
        final data = response.body?['data'];
        // API returns: { "data": { "booking": { "_id": "..." } } }
        _lastBookingId =
            data?['booking']?['_id']?.toString() ??
            data?['booking']?['id']?.toString() ??
            data?['_id']?.toString() ??
            data?['id']?.toString();

        debugPrint('✅ BookingController: Booking ID parsed: $_lastBookingId');

        _isLoading = false;
        notifyListeners();
        return _lastBookingId;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to create booking";
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    try {
      final response = await NetworkCaller.patchRequest(
        url: Urls.updateBookingStatus(bookingId),
        body: {"status": status},
        requireAuth: true,
      );
      debugPrint(
        '📋 BookingController: Status update to "$status" → success: ${response.isSuccess}',
      );
      return response.isSuccess;
    } catch (e) {
      debugPrint('❌ BookingController: Status update failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> calculateBookingPrice({
    required String serviceId,
    required String bookingDate,
    required String startTime,
    String? endTime,
    String? packageName,
    double distanceFromProviderKm = 0.0,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final Map<String, dynamic> body = {
      "serviceId": serviceId,
      "date": bookingDate,
      "startTime": startTime,
      "distanceFromProviderKm": distanceFromProviderKm,
    };

    if (endTime != null && endTime.isNotEmpty) {
      body["endTime"] = endTime;
    }

    if (packageName != null && packageName.isNotEmpty) {
      body["packageName"] = packageName;
    }

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.calculateBookingPrice,
        body: body,
      );

      if (response.isSuccess) {
        _isLoading = false;
        notifyListeners();
        return response.body?['data'];
      } else {
        _errorMessage = response.errorMessage ?? "Failed to calculate price";
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
