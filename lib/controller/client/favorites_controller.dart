import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';

class FavoritesController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _favoritePosts = [];
  List<Map<String, dynamic>> _favoriteProviders = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get favoritePosts => _favoritePosts;
  List<Map<String, dynamic>> get favoriteProviders => _favoriteProviders;

  Future<void> fetchFavorites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final NetworkResponse response = await NetworkCaller.getRequest(
        url: Urls.getFavorites,
      );

      if (response.isSuccess && response.body != null) {
        final List<dynamic> data = response.body?['data'] ?? [];
        _favoritePosts = [];
        _favoriteProviders = [];

        for (var item in data) {
          if (item['serviceId'] != null) {
            _favoritePosts.add(item['serviceId']);
          } else if (item['providerId'] != null) {
            _favoriteProviders.add(item['providerId']);
          }
        }
      } else {
        _errorMessage = response.errorMessage ?? "Failed to fetch favorites";
      }
    } catch (e) {
      _errorMessage = "An unexpected error occurred while fetching favorites";
      debugPrint("fetchFavorites error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite({
    String? serviceId,
    String? providerId,
    Map<String, dynamic>? optimisticData,
  }) async {
    final Map<String, dynamic> body = {};
    if (serviceId != null) {
      body['service'] = serviceId;
      body['favouriteType'] = 'service';
    } else if (providerId != null) {
      body['provider'] = providerId;
      body['favouriteType'] = 'professional';
    }

    if (body.isEmpty) {
      debugPrint("toggleFavorite: Both serviceId and providerId are null.");
      return false;
    }

    bool wasFavorite = false;
    if (serviceId != null) {
      wasFavorite = isPostFavorite(serviceId);
      if (wasFavorite) {
        _favoritePosts.removeWhere((p) => (p['_id'] ?? p['id']) == serviceId);
      } else if (optimisticData != null) {
        _favoritePosts.add(optimisticData);
      }
    } else if (providerId != null) {
      wasFavorite = isProviderFavorite(providerId);
      if (wasFavorite) {
        _favoriteProviders.removeWhere(
          (p) => (p['_id'] ?? p['id']) == providerId,
        );
      } else if (optimisticData != null) {
        _favoriteProviders.add(optimisticData);
      }
    }
    notifyListeners();

    try {
      final NetworkResponse response = await NetworkCaller.postRequest(
        url: Urls.toggleFav,
        body: body,
      );

      if (!response.isSuccess) {
        // Revert optimistic update on failure
        await fetchFavorites();
        return false;
      }
      // Refresh to ensure synced with server
      await fetchFavorites();
      return true;
    } catch (e) {
      debugPrint("toggleFavorite error: $e");
      await fetchFavorites();
      return false;
    }
  }

  bool isProviderFavorite(dynamic id) {
    if (id == null) return false;
    final String idStr = id is Map ? (id['_id']?.toString() ?? id['id']?.toString() ?? id.toString()) : id.toString();
    return _favoriteProviders.any(
      (element) => (element['_id']?.toString() ?? element['id']?.toString()) == idStr,
    );
  }

  bool isPostFavorite(dynamic id) {
    if (id == null) return false;
    final String idStr = id is Map ? (id['_id']?.toString() ?? id['id']?.toString() ?? id.toString()) : id.toString();
    return _favoritePosts.any(
      (element) => (element['_id']?.toString() ?? element['id']?.toString()) == idStr,
    );
  }
}
