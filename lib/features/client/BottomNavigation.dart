// lib/features/client/BottomNavigation.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/home_page.dart';
import 'package:photopia/features/client/user_profile_screen.dart';
import 'package:photopia/features/client/favorites_screen.dart';
import 'package:photopia/features/client/messages_screen.dart';
import 'package:photopia/features/client/search_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});
  static const String name = "/bottom-navigation";

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  // Use keys for each navigator to maintain state and allow internal navigation
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      // If tapping the already selected tab, pop to the first route
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detect if keyboard is visible
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent push up
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildTabNavigator(0, const MyHomePage()),
          _buildTabNavigator(1, const MessagesScreen()),

          //now i change this screen when client change any UI so i update that
          _buildTabNavigator(2, const SearchScreen()),
          //now i change this screen when client change any UI so i update that

          _buildTabNavigator(3, const FavoritesScreen()),
          _buildTabNavigator(4, const UserProfileScreen()),
        ],
      ),
      bottomNavigationBar: isKeyboardVisible
          ? const SizedBox.shrink() // Completely hide when keyboard is open
          : Container(
              color: Colors.white,
              child: SafeArea(
                bottom: true,
                child: Container(
                  height: 70,
                  clipBehavior: Clip.none,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildNavItem(
                          index: 0,
                          iconAsset: 'assets/images/client_home_icon.png',
                          label: 'Home',
                        ),
                      ),
                      Expanded(
                        child: _buildNavItem(
                          index: 1,
                          iconAsset: 'assets/images/message_icon.png',
                          label: 'Messages',
                        ),
                      ),
                      Expanded(child: _buildSearchButton()),
                      Expanded(
                        child: _buildNavItem(
                          index: 3,
                          iconAsset: 'assets/images/client_favorite_icon.png',
                          label: 'Favorites',
                        ),
                      ),
                      Expanded(
                        child: _buildNavItem(
                          index: 4,
                          iconAsset: 'assets/images/client_profile_icon.png',
                          label: 'Profile',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTabNavigator(int index, Widget rootPage) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => rootPage,
        );
      },
    );
  }

  Widget _buildSearchButton() {
    bool isSelected = _selectedIndex == 2;
    return Transform.translate(
      offset: const Offset(0, -20),
      child: GestureDetector(
        onTap: () => _onItemTapped(2),
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: const Icon(
            Icons.search,
            color: Colors.grey,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    IconData? icon,
    String? iconAsset,
    required String label,
  }) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconAsset != null)
            Image.asset(
              iconAsset,
              width: 22.sp.clamp(20, 24),
              height: 22.sp.clamp(20, 24),
              color: isSelected ? Colors.black : Colors.grey,
            )
          else if (icon != null)
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey,
              size: 22.sp.clamp(20, 24),
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontSize: 11.sp.clamp(10, 12),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
