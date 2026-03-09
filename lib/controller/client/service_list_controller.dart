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

  Future<bool> getAllServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await NetworkCaller.getRequest(
      url: Urls.getAllservice,
      requireAuth: false, // Public endpoint
    );

    _isLoading = false;

    if (response.isSuccess && response.body != null) {
      try {
        final model = ServiceListModel.fromJson(response.body!);
        _services = model.data?.data ?? [];
        notifyListeners();
        return true;
      } catch (e) {
        _errorMessage = "Error parsing data: $e";
        debugPrint("ServiceListController parsing error: $e");
        notifyListeners();
        return false;
      }
    } else {
      _errorMessage = response.errorMessage ?? "Failed to fetch services";
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
