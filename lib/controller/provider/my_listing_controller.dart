import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/my_listing_model.dart';

class MyListingController extends ChangeNotifier {
  bool _isProgress = false;
  String? _errorMessage;
  MyListingModel? _myListingModel;

  bool get isProgress => _isProgress;
  String? get errorMessage => _errorMessage;
  MyListingModel? get myListingModel => _myListingModel;

  List<Listing> get listings => _myListingModel?.data?.data ?? [];

  // Statistics
  int get totalListings => listings.length;
  int get activeListings =>
      listings.where((l) => l.status?.toLowerCase() == 'active').length;
  int get draftListings => listings
      .where(
        (l) =>
            l.status?.toLowerCase() == 'drafts' ||
            l.status?.toLowerCase() == 'draft',
      )
      .length;
  int get pastListings =>
      listings.where((l) => l.status?.toLowerCase() == 'past').length;

  Future<bool> getMyListings() async {
    _isProgress = true;
    _errorMessage = null;
    notifyListeners();

    final response = await NetworkCaller.getRequest(url: Urls.myListingApi);

    if (response.isSuccess && response.body != null) {
      _myListingModel = MyListingModel.fromJson(response.body!);
      _isProgress = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.errorMessage ?? "Failed to load listings";
      _isProgress = false;
      notifyListeners();
      return false;
    }
  }
}
