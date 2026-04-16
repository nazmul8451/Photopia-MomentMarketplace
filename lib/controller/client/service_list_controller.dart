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

  List<ServiceItem> _filteredServices = [];
  bool _isFiltered = false;
  bool get isFiltered => _isFiltered;

  List<ServiceItem> get displayServices =>
      _isFiltered ? _filteredServices : _services;

  ServiceItem? _serviceDetail;
  ServiceItem? get serviceDetail => _serviceDetail;

  Future<bool> getAllServices({Map<String, dynamic>? filters, bool refresh = true}) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    if (refresh) {
      _services = []; // Clear current list while loading only if refresh is true
    }
    notifyListeners();

    try {
      String url = Urls.getAllservice;

      if (filters != null && filters.isNotEmpty) {
        final queryParams = <String>[];
        filters.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            if (value is List) {
              for (var item in value) {
                queryParams.add('$key=$item');
              }
            } else {
              queryParams.add('$key=$value');
            }
          }
        });
        if (queryParams.isNotEmpty) {
          url += (url.contains('?') ? '&' : '?') + queryParams.join('&');
        }
      }

      debugPrint("🚀 [SERVICES] Fetching URL: $url");
      final response = await NetworkCaller.getRequest(
        url: url,
        requireAuth: false,
      );

      _isLoading = false;

      if (response.isSuccess && response.body != null) {
        final model = ServiceListModel.fromJson(response.body!);
        _services = model.data?.data ?? [];
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

  // Filter services by category ID
  List<ServiceItem> getServicesByCategoryId(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) return _services;
    return _services.where((s) => s.category?.id == categoryId).toList();
  }

  // Filter services by subcategory ID
  List<ServiceItem> getServicesBySubCategoryId(String? subCategoryId) {
    if (subCategoryId == null || subCategoryId.isEmpty) return _services;
    return _services.where((s) => s.subCategory == subCategoryId).toList();
  }

  void applyFavoritesFilter(bool showOnlyFavorites, List<String> favoriteIds) {
    _isFiltered = showOnlyFavorites;
    if (showOnlyFavorites) {
      _filteredServices = _services.where((service) {
        final id = service.sId;
        return favoriteIds.contains(id);
      }).toList();
    } else {
      _filteredServices = [];
    }
    notifyListeners();
  }

  void resetFilters() {
    _isFiltered = false;
    _filteredServices = [];
    notifyListeners();
  }
}
