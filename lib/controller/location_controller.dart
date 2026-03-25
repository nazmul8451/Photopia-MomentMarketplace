import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationController extends ChangeNotifier {
  String _currentAddress = "Detecting location...";
  String get currentAddress => _currentAddress;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> determinePosition() async {
    _isLoading = true;
    notifyListeners();

    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _currentAddress = "Location services disabled";
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
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      // Formatted address: City, Country OR SubLocality, City
      if (place.locality != null && place.locality!.isNotEmpty) {
        _currentAddress = "${place.locality}, ${place.country}";
      } else {
        _currentAddress = "${place.subLocality}, ${place.locality}";
      }
    } catch (e) {
      _currentAddress = "Unknown Location";
      debugPrint("Geocoding Error: $e");
    }
  }
}
