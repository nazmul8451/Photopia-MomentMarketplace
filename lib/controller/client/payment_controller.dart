import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';

class PaymentController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initializes the Stripe Payment Sheet by calling the backend
  Future<bool> initPaymentSheet({
    required String bookingId,
    required double amount,
    required String currency,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Call backend to create PaymentIntent
      final NetworkResponse response = await NetworkCaller.postRequest(
        url: Urls.createPaymentIntent,
        body: {
          'bookingId': bookingId,
          'amount': amount.toInt(), // Match Postman body (e.g. 20)
        },
      );


      if (response.isSuccess && response.body != null) {
        final data = response.body!['data'];
        // Match camelCase from Postman screenshot
        final clientSecret = data['clientSecret'] ?? data['client_secret'];
        final ephemeralKey = data['ephemeralKey'];
        final customerId = data['customerId'];

        if (clientSecret == null) {
          _errorMessage = "Missing clientSecret from server";
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // 2. Initialize Payment Sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            customerEphemeralKeySecret: ephemeralKey,
            customerId: customerId,
            merchantDisplayName: 'Photopia',
            style: ThemeMode.light,
          ),
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to initialize payment";
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

  /// Displays the initialized Payment Sheet
  Future<bool> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      // If no error is thrown, payment was successful or handled by webhook
      return true;
    } on StripeException catch (e) {
      _errorMessage = e.getAppError().message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Helper to convert Stripe error to human readable message
}

extension StripeErrorExtension on StripeException {
  LocalizedErrorMessage getAppError() {
    return error;
  }
}
