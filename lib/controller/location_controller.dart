import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/controller/auth_controller.dart';

class LocationController extends ChangeNotifier {
  String _currentAddress = "Detecting location...";
  String get currentAddress => _currentAddress;

  double? _latitude;
  double? _longitude;
  String? _city;
  String? _country;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get city => _city;
  String? get country => _country;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  List<dynamic> _searchSuggestions = [];
  List<dynamic> get searchSuggestions => _searchSuggestions;

  Future<void> determinePosition() async {
    _isLoading = true;
    notifyListeners();

    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _currentAddress = "Location Services Off (Turn on GPS)";
        _isLoading = false;
        notifyListeners();
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _currentAddress = "Location permission denied";
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _currentAddress = "Location permissions permanently denied";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      await _getAddressFromLatLng(position);
    } catch (e) {
      _currentAddress = "Error getting location";
      debugPrint("Location Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      _latitude = position.latitude;
      _longitude = position.longitude;

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _city = place.locality ?? place.subLocality;
        _country = place.country;

        // Formatted address: City, Country OR SubLocality, City
        if (place.locality != null && place.locality!.isNotEmpty) {
          _currentAddress = "${place.locality}, ${place.country}";
        } else {
          _currentAddress = "${place.subLocality}, ${place.locality}";
        }
      }
    } catch (e) {
      _currentAddress = "Unknown Location";
      debugPrint("Geocoding Error: $e");
    }
  }

  // --- Backend API Integration ---

  Future<List<dynamic>> searchLocations(String query) async {
    if (query.isEmpty) {
      _searchSuggestions = [];
      notifyListeners();
      return [];
    }

    _isSearching = true;
    notifyListeners();

    try {
      final String? token = AuthController.accessToken;
      final Uri uri = Uri.parse("${Urls.locationSearch}?q=${Uri.encodeComponent(query)}");
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': token != null ? (token.startsWith('Bearer ') ? token : 'Bearer $token') : '',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _searchSuggestions = data['data'] ?? [];
          return _searchSuggestions;
        }
      }
      return [];
    } catch (e) {
      debugPrint("Location Search Error: $e");
      return [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> geocodeAddress(String address) async {
    if (address.isEmpty) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final String? token = AuthController.accessToken;
      final Uri uri = Uri.parse("${Urls.locationGeocode}?address=${Uri.encodeComponent(address)}");
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': token != null ? (token.startsWith('Bearer ') ? token : 'Bearer $token') : '',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final geocodedData = data['data'];
          if (geocodedData != null) {
            _latitude = double.tryParse(geocodedData['lat']?.toString() ?? '');
            _longitude = double.tryParse(geocodedData['lng']?.toString() ?? '');
            // You can also update city/country here if the backend returns them
            // The current documentation only shows lat, lng, formattedAddress, placeId
            return geocodedData;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint("Geocode Error: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
