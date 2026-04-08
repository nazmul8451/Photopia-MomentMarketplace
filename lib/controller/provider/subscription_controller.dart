import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/user_profile_controller.dart';
import 'package:photopia/controller/provider/provider_profile_controller.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/subscription_plan_model.dart';

class SubscriptionController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  SubscriptionPlanModel? _planModel;
  bool _isAlreadySubscribed = false;
  String? _termsContent;
  String? _privacyContent;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SubscriptionPlanModel? get planModel => _planModel;
  bool get isAlreadySubscribed => _isAlreadySubscribed;
  String? get termsContent => _termsContent;
  String? get privacyContent => _privacyContent;

  Future<void> fetchTermsAndConditions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(url: Urls.termsAndConditions);
      if (response.isSuccess && response.body != null) {
        _termsContent = response.body!['data']['content'];
      } else {
        _errorMessage = response.errorMessage ?? "Failed to load terms";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch all available subscription plans
  Future<void> fetchPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(url: Urls.subscriptionPlans);
      if (response.isSuccess && response.body != null) {
        _planModel = SubscriptionPlanModel.fromJson(response.body!);
      } else {
        _errorMessage = response.errorMessage ?? "Failed to load plans";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initiates subscription creation and payment flow
  Future<bool> createSubscription(BuildContext context, String planId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Create subscription on backend
      final response = await NetworkCaller.postRequest(
        url: Urls.createSubscription,
        body: {
          'planId': planId,
        },
      );

      if (response.isSuccess && response.body != null) {
        final data = response.body!['data'];
        final clientSecret = data['clientSecret'];

        if (clientSecret == null) {
          _errorMessage = "Missing payment information from server";
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // 2. Initialize Payment Sheet for SetupIntent (subscription)
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            setupIntentClientSecret: clientSecret,
            customerId: data['subscription']?['stripeCustomerId'],
            merchantDisplayName: 'Photopia',
            style: ThemeMode.light,
          ),
        );

        // 3. Present Payment Sheet
        await Stripe.instance.presentPaymentSheet();

        // 4. IMMEDIATE FEEDBACK: Update local state before refreshing
        _isAlreadySubscribed = true;
        _isLoading = false;
        notifyListeners();

        // 5. REFRESH PROFILES: Update global state from server
        if (context.mounted) {
          Provider.of<UserProfileController>(context, listen: false).getUserProfile();
          Provider.of<ProviderProfileController>(context, listen: false).getProviderProfile();
        }

        return true;
      } else {
        if (response.statusCode == 409) {
          _isAlreadySubscribed = true;
        }
        _errorMessage = response.errorMessage ?? "Failed to create subscription";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on StripeException catch (e) {
      _errorMessage = e.error.localizedMessage ?? "Payment failed";
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _planModel = null;
    _isAlreadySubscribed = false;
    _termsContent = null;
    _privacyContent = null;
    notifyListeners();
  }
}
