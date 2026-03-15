import 'package:flutter/material.dart';

class BottomNavController extends ChangeNotifier {
  int _selectedIndex = 0; // Default to Orders tab

  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void resetToHome() {
    _selectedIndex = 0;
    notifyListeners();
  }
}
