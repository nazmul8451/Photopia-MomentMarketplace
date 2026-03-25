import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/review_model.dart';

class ReviewController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ReviewResponse? _reviewResponse;
  ReviewResponse? get reviewResponse => _reviewResponse;

  List<ReviewItem> get reviews => _reviewResponse?.data?.reviews ?? [];
  
  int get totalReviews => _reviewResponse?.data?.meta?.total ?? 0;

  Future<void> getProviderReviews(String providerId) async {
    _isLoading = true;
    _reviewResponse = null;
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.getReviewsByProvider(providerId),
      );

      if (response.isSuccess && response.body != null) {
        _reviewResponse = ReviewResponse.fromJson(response.body!);
      } else {
        debugPrint("Failed to fetch reviews: ${response.errorMessage}");
      }
    } catch (e) {
      debugPrint("Error fetching reviews: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
