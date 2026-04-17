import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';

class ProviderOrdersController extends ChangeNotifier {
  bool _inProgress = false;
  String _errorMessage = '';
  List<dynamic> _orders = [];

  // Categorized lists for stable state management
  List<dynamic> _todayOrders = [];
  List<dynamic> _upcomingOrders = [];
  List<dynamic> _pendingOrders = [];

  // Categorized loading states
  bool _todayLoading = false;
  bool _upcomingLoading = false;
  bool _pendingLoading = false;

  bool get inProgress => _inProgress;
  String get errorMessage => _errorMessage;
  List<dynamic> get orders => _orders;

  // Granular Getters
  List<dynamic> get todayOrders => _todayOrders;
  List<dynamic> get upcomingOrders => _upcomingOrders;
  List<dynamic> get pendingOrders => _pendingOrders;

  bool get todayLoading => _todayLoading;
  bool get upcomingLoading => _upcomingLoading;
  bool get pendingLoading => _pendingLoading;

  Future<bool> getMyOrders({String? filterType, String? status}) async {
    // Determine which category is loading
    if (filterType == 'today') {
      _todayLoading = true;
    } else if (filterType == 'upcoming') {
      _upcomingLoading = true;
    } else if (status == 'pending') {
      _pendingLoading = true;
    } else {
      _inProgress = true;
    }
    
    _errorMessage = '';
    notifyListeners();

    final response = await NetworkCaller.getRequest(
      url: Urls.getMyOrders(filterType: filterType, status: status)
    );

    // Reset all loading states
    _todayLoading = false;
    _upcomingLoading = false;
    _pendingLoading = false;
    _inProgress = false;

    if (response.isSuccess) {
      if (response.body != null && response.body!['data'] != null) {
        final data = response.body!['data'];
        
        // Populate the correct category
        if (filterType == 'today') {
          _todayOrders = data;
        } else if (filterType == 'upcoming') {
          _upcomingOrders = data;
        } else if (status == 'pending') {
          _pendingOrders = data;
        }
        
        _orders = data; // Keep for backward compatibility
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
      // Refresh all relevant categories in the background for a "real-time" feel
      getMyOrders(filterType: 'today');
      getMyOrders(filterType: 'upcoming');
      getMyOrders(status: 'pending');
      return true;
    }
    return false;
  }

  void reset() {
    _inProgress = false;
    _isUpdating = false;
    _errorMessage = '';
    _orders = [];
    _todayOrders = [];
    _upcomingOrders = [];
    _pendingOrders = [];
    _todayLoading = false;
    _upcomingLoading = false;
    _pendingLoading = false;
    notifyListeners();
  }
}
