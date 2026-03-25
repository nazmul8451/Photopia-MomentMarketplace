import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/wallet_model.dart';

class WalletController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  WalletData? _walletData;
  WalletData? get walletData => _walletData;

  num get balance => _walletData?.balance ?? 0;
  num get pendingBalance => _walletData?.pendingBalance ?? 0;
  num get totalEarnings => _walletData?.totalEarnings ?? 0;
  num get totalBalance => (balance + pendingBalance);

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
}
