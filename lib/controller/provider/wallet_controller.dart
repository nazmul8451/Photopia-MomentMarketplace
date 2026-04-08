import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/wallet_model.dart';
import 'package:photopia/data/models/stripe_connect_model.dart';

class WalletController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  WalletData? _walletData;
  WalletData? get walletData => _walletData;

  num get balance => _walletData?.balance ?? 0;
  num get pendingBalance => _walletData?.pendingBalance ?? 0;
  num get totalEarnings => _walletData?.totalEarnings ?? 0;
  num get totalBalance => (balance + pendingBalance);
  
  StripeConnectStatus? _stripeStatus;
  StripeConnectStatus? get stripeStatus => _stripeStatus;

  bool get isStripeReady => 
      _stripeStatus?.isComplete == true && 
      _stripeStatus?.detailsSubmitted == true &&
      _stripeStatus?.payoutsEnabled == true;

  Future<void> getMyWallet() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.myWallet,
      );

      if (response.isSuccess && response.body != null) {
        final walletRes = WalletResponse.fromJson(response.body!);
        _walletData = walletRes.data;
      } else {
        debugPrint("Failed to fetch wallet: ${response.errorMessage}");
      }
    } catch (e) {
      debugPrint("Error fetching wallet: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> getStripeStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.stripeConnectStatus,
      );

      if (response.isSuccess && response.body != null) {
        final statusRes = StripeConnectStatusResponse.fromJson(response.body!);
        _stripeStatus = statusRes.data;
        return true;
      } else {
        debugPrint("Failed to fetch stripe status: ${response.errorMessage}");
      }
    } catch (e) {
      debugPrint("Error fetching stripe status: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<String?> getStripeOnboardingUrl() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.stripeOnboarding,
        body: {},
      );

      if (response.isSuccess && response.body != null) {
        final onboardingRes = StripeOnboardingResponse.fromJson(response.body!);
        return onboardingRes.data.url;
      } else {
        debugPrint("Failed to fetch onboarding url: ${response.errorMessage}");
      }
    } catch (e) {
      debugPrint("Error fetching onboarding url: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<bool> createWithdrawal(double amount) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.createWithdrawal,
        body: {"amount": amount},
      );

      if (response.isSuccess) {
        // Refresh wallet data after successful withdrawal
        await getMyWallet();
        return true;
      } else {
        debugPrint("Withdrawal failed: ${response.errorMessage}");
        // We could store the error message if needed
        return false;
      }
    } catch (e) {
      debugPrint("Error creating withdrawal: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _walletData = null;
    _stripeStatus = null;
    _isLoading = false;
    notifyListeners();
  }
}
