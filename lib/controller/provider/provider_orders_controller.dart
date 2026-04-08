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

  Future<bool> getMyOrders({String? filterType, String? status}) async {
    _inProgress = true;
    _errorMessage = '';
    _orders = []; // Clear previous data so shimmering feels clean and accurate for the new tab focus
    notifyListeners();

    final response = await NetworkCaller.getRequest(
      url: Urls.getMyOrders(filterType: filterType, status: status)
    );

    _inProgress = false;

    if (response.isSuccess) {
      if (response.body != null && response.body!['data'] != null) {
        _orders = response.body!['data'];
        debugPrint("Fetched ${_orders.length} orders");
        if (_orders.isNotEmpty) {
          debugPrint("First order FULL JSON: $_orders");
        }
      }
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.errorMessage ?? 'Failed to fetch orders';
      notifyListeners();
      return false;
    }
  }

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  Future<bool> updateOrderStatus(String bookingId, String status) async {
    _isUpdating = true;
    notifyListeners();

    final response = await NetworkCaller.patchRequest(
      url: Urls.updateBookingStatus(bookingId),
      body: {'status': status},
    );

    _isUpdating = false;
    notifyListeners();

    if (response.isSuccess) {
      await getMyOrders(); // Refresh the list
      return true;
    }
    return false;
  }

  void reset() {
    _inProgress = false;
    _isUpdating = false;
    _errorMessage = '';
    _orders = [];
    notifyListeners();
  }
}
