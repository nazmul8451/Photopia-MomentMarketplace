// lib/features/client/BottomNavigation.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/home_page.dart';
import 'package:photopia/features/client/user_profile_screen.dart';
import 'package:photopia/features/client/favorites_screen.dart';
import 'package:photopia/features/client/messages_screen.dart';
import 'package:photopia/features/client/search_screen.dart';
import 'package:photopia/features/client/authentication/log_in_screen.dart';
import 'package:photopia/features/client/authentication/sign_up_screen.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/controller/client/service_list_controller.dart';
import 'package:photopia/core/utils/guest_dialog_helper.dart';
import 'package:provider/provider.dart';

import 'package:photopia/controller/client/booking_controller.dart';
import 'package:photopia/core/notification/notification_service.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});
  static const String name = "/bottom-navigation";

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize notification service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.init();
    });
  }

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
    // Guest check for restricted tabs: Messages (1), Favorites (3)
    if (index == 1 || index == 3 || index == 4) {
      if (!AuthController.isLoggedIn) {
        GuestDialogHelper.showGuestDialog(context);
        return;
      }
    }

    if (_selectedIndex == index) {
      // If tapping the already selected tab, pop to the first route
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);

      // Refresh Home data if already on Home and tapping again
      if (index == 0) {
        context.read<ServiceListController>().getAllServices(refresh: true);
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });

      // Refresh bookings if switching to Profile tab
      if (index == 4) {
        context.read<BookingController>().getMyBookings();
      }
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
          ? const SizedBox.shrink()
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 65.h,
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
        return MaterialPageRoute(builder: (context) => rootPage);
      },
    );
  }

  Widget _buildSearchButton() {
    bool isSelected = _selectedIndex == 2;
    return Transform.translate(
      offset: Offset(0, -28.h),
      child: GestureDetector(
        onTap: () => _onItemTapped(2),
        child: Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.search,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
            size: 26.sp,
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
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconAsset != null)
            Image.asset(
              iconAsset,
              width: 24.w,
              height: 24.w,
              color: isSelected ? Colors.black : Colors.grey[400],
            )
          else
            Icon(
              icon,
              size: 24.sp,
              color: isSelected ? Colors.black : Colors.grey[400],
            ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: isSelected ? Colors.black : Colors.grey[400],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
