import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';

class ProviderOrdersController extends ChangeNotifier {
  bool _inProgress = false;
  String _errorMessage = '';
  List<dynamic> _orders = [];

  bool get inProgress => _inProgress;
  String get errorMessage => _errorMessage;
  List<dynamic> get orders => _orders;

  Future<bool> getMyOrders() async {
    _inProgress = true;
    _errorMessage = '';
    notifyListeners();

    final response = await NetworkCaller.getRequest(url: Urls.getMyOrders);

    _inProgress = false;

    if (response.isSuccess) {
      if (response.body != null && response.body!['data'] != null) {
        _orders = response.body!['data'];
      }
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.errorMessage ?? 'Failed to fetch orders';
      notifyListeners();
      return false;
    }
  }
}
