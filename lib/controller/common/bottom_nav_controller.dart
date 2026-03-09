import 'package:flutter/material.dart';

class BottomNavController extends ChangeNotifier {
  int _selectedIndex = 2; // Default to Listing tab

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void resetToHome() {
    _selectedIndex = 2;
    notifyListeners();
  }
}
