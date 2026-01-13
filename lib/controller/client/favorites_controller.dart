import 'package:flutter/material.dart';

class FavoritesController extends ChangeNotifier {
  // Store full objects for easy UI rendering without secondary lookup
  // In a real API scenario, these might be IDs and we'd fetch details
  final List<Map<String, dynamic>> _favoritePosts = [];
  final List<Map<String, dynamic>> _favoriteProviders = [];

  List<Map<String, dynamic>> get favoritePosts => _favoritePosts;
  List<Map<String, dynamic>> get favoriteProviders => _favoriteProviders;

  void toggleFavoritePost(Map<String, dynamic> service) {
    final index = _favoritePosts.indexWhere((element) => element['title'] == service['title']);
    if (index >= 0) {
      _favoritePosts.removeAt(index);
    } else {
      _favoritePosts.add(service);
    }
    notifyListeners();
  }

  void toggleFavoriteProvider(Map<String, dynamic> provider) {
    final index = _favoriteProviders.indexWhere((element) => element['name'] == provider['name']);
    if (index >= 0) {
      _favoriteProviders.removeAt(index);
    } else {
      _favoriteProviders.add(provider);
    }
    notifyListeners();
  }

  bool isPostFavorite(String title) {
    return _favoritePosts.any((element) => element['title'] == title);
  }

  bool isProviderFavorite(String name) {
    return _favoriteProviders.any((element) => element['name'] == name);
  }
}
