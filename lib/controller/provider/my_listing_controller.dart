import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/my_listing_model.dart';
import 'package:photopia/data/models/provider_service_model.dart'
    as service_model;

class MyListingController extends ChangeNotifier {
  bool _isProgress = false;
  String? _errorMessage;
  MyListingModel? _myListingModel;

  bool get isProgress => _isProgress;
  String? get errorMessage => _errorMessage;
  MyListingModel? get myListingModel => _myListingModel;

  bool _isSingleListingProgress = false;
  service_model.Data? _singleListingData;

  bool get isSingleListingProgress => _isSingleListingProgress;
  service_model.Data? get singleListingData => _singleListingData;

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

    try {
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
    } catch (e) {
      _errorMessage = "An unexpected error occurred while loading listings";
      _isProgress = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> getSingleListing(String id) async {
    _isSingleListingProgress = true;
    _errorMessage = null;
    _singleListingData = null;
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.getSingleList(id),
      );

      if (response.isSuccess && response.body != null) {
        final serviceModel = service_model.ProviderServiceModel.fromJson(
          response.body!,
        );
        _singleListingData = serviceModel.data;
        _isSingleListingProgress = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            response.errorMessage ?? "Failed to load listing details";
        _isSingleListingProgress = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "An unexpected error occurred while loading details";
      _isSingleListingProgress = false;
      notifyListeners();
      return false;
    }
  }

  void removeListingLocal(String id) {
    if (_myListingModel?.data?.data != null) {
      _myListingModel!.data!.data!.removeWhere((listing) => listing.sId == id);
      notifyListeners();
    }
  }
}
