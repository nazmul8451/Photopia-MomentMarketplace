import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/category_model.dart';

class CategoryController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  List<CategoryModel> _subCategories = [];
  List<CategoryModel> get subCategories => _subCategories;

  List<CategoryModel> _popularCategories = [];
  List<CategoryModel> get popularCategories => _popularCategories;

  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;

  String? _selectedSubCategoryId;
  String? get selectedSubCategoryId => _selectedSubCategoryId;

  // Root categories (type == 'category')
  List<CategoryModel> get rootCategories =>
      _categories.where((c) => c.type == 'category').toList();

  // Select a category and fetch its subcategories
  Future<void> selectCategory(String? categoryId) async {
    _selectedCategoryId = categoryId;
    _selectedSubCategoryId = null; // Reset subcategory when category changes
    _subCategories = [];
    notifyListeners();

    if (categoryId != null) {
      await fetchSubCategories(categoryId);
    }
  }

  void selectSubCategory(String? subCategoryId) {
    _selectedSubCategoryId = subCategoryId;
    notifyListeners();
  }

  Future<void> getAllCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.categories,
        requireAuth: false,
      );

      if (response.isSuccess && response.body != null) {
        final dynamic rawData = response.body?['data'];
        List<dynamic> listData = [];

        if (rawData is Map && rawData.containsKey('data')) {
          listData = rawData['data'] as List<dynamic>;
        } else if (rawData is List) {
          listData = rawData;
        }

        _categories = listData
            .map((json) => CategoryModel.fromJson(json))
            .toList();
      } else {
        _errorMessage =
            response.body?['message'] ?? 'Failed to fetch categories';
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSubCategories(String parentId) async {
    // If we already have categories, filter locally first for speed
    final localSub = _categories.where((c) => c.parent == parentId).toList();
    if (localSub.isNotEmpty) {
      _subCategories = localSub;
      notifyListeners();
      return;
    }

    // If not found locally, try API with parent query parameter as per guide
    try {
      final response = await NetworkCaller.getRequest(
        url: '${Urls.categories}?parent=$parentId&type=subcategory',
        requireAuth: false,
      );

      if (response.isSuccess && response.body != null) {
        final dynamic rawData = response.body?['data'];
        List<dynamic> listData = [];

        if (rawData is Map && rawData.containsKey('data')) {
          listData = rawData['data'] as List<dynamic>;
        } else if (rawData is List) {
          listData = rawData;
        }

        _subCategories = listData
            .map((json) => CategoryModel.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching subcategories: $e');
    }
  }

  Future<void> getPopularCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.popularCategories,
        requireAuth: false,
      );

      if (response.isSuccess && response.body != null) {
        final dynamic rawData = response.body?['data'];
        List<dynamic> listData = [];

        if (rawData is List) {
          listData = rawData;
        } else if (rawData is Map && rawData.containsKey('data')) {
          listData = rawData['data'] as List<dynamic>;
        }

        _popularCategories = listData
            .map((json) => CategoryModel.fromJson(json))
            .toList();
      } else {
        _errorMessage =
            response.body?['message'] ?? 'Failed to fetch popular categories';
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching popular categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _categories = [];
    _popularCategories = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
