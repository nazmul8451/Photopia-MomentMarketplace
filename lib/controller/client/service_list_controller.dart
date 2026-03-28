import 'package:flutter/foundation.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/service_list_model.dart';

class ServiceListController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ServiceItem> _services = [];
  List<ServiceItem> get services => _services;

  ServiceItem? _serviceDetail;
  ServiceItem? get serviceDetail => _serviceDetail;

  Future<bool> getAllServices() async {
    _isLoading = true;
    _errorMessage = null;
    _services = []; // Clear current list while loading
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.service,
        requireAuth: false,
      );

      _isLoading = false;

      if (response.isSuccess && response.body != null) {
        final model = ServiceListModel.fromJson(response.body!);
        _services = model.data?.data ?? [];
        // DEBUG: print coverMedia URLs to trace image loading issues
        for (var s in _services.take(3)) {
          debugPrint('🖼️ [ServiceCard] coverMedia=${s.coverMedia} | title=${s.title}');
        }
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to fetch services";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Parsing error: $e";
      debugPrint("getAllServices error: $e");
      notifyListeners();
      return false;
    }
  }

  Future<bool> getProviderServices(String providerId) async {
    _isLoading = true;
    _errorMessage = null;
    _services = [];
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.getServicesByProvider(providerId),
        requireAuth: false,
      );

      _isLoading = false;

      if (response.isSuccess && response.body != null) {
        final model = ServiceListModel.fromJson(response.body!);
        _services = model.data?.data ?? [];
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            response.errorMessage ?? "Failed to fetch provider services";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Parsing error: $e";
      debugPrint("getProviderServices error: $e");
      notifyListeners();
      return false;
    }
  }

  Future<bool> getServiceById(String id) async {
    _isLoading = true;
    _serviceDetail = null;
    _errorMessage = null;
    notifyListeners();

    final response = await NetworkCaller.getRequest(
      url: Urls.getSingleList(id),
      requireAuth: false,
    );

    _isLoading = false;

    if (response.isSuccess && response.body != null) {
      try {
        final data = response.body!['data'];
        _serviceDetail = ServiceItem.fromJson(data);
        notifyListeners();
        return true;
      } catch (e) {
        _errorMessage = "Error parsing detail data: $e";
        debugPrint("ServiceListController parsing error: $e");
        notifyListeners();
        return false;
      }
    } else {
      _errorMessage =
          response.errorMessage ?? "Failed to fetch service details";
      notifyListeners();
      return false;
    }
  }

  // Filter services by category if needed (local filtering for now)
  List<ServiceItem> getServicesByCategory(String? categoryName) {
    if (categoryName == null || categoryName.isEmpty) return _services;
    return _services.where((s) => s.category?.name == categoryName).toList();
  }
}
