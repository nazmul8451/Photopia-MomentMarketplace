import 'package:flutter/material.dart';
import 'package:photopia/features/provider/screen/provider_orders_screen.dart';
import 'package:photopia/features/provider/screen/provider_calendar_screen.dart';
import 'package:photopia/features/provider/screen/provider_overview_screen.dart';
import 'package:photopia/features/provider/screen/provider_message_screen.dart';
import 'package:photopia/features/provider/screen/provider_menu_screen.dart';
import 'package:photopia/features/provider/widgets/provider_custom_bottom_nav_bar.dart';

class ProviderBottomNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const ProviderBottomNavigationScreen({super.key, this.initialIndex = 0});
  static const String name = "/provider-bottom-navigation";

  @override
  State<ProviderBottomNavigationScreen> createState() => _ProviderBottomNavigationScreenState();
}

class _ProviderBottomNavigationScreenState extends State<ProviderBottomNavigationScreen> {
  late int _selectedIndex;
  
  // Navigation keys for each tab
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemSelected(int index) {
    if (_selectedIndex == index) {
      // If tapping the same tab, pop to the first screen of that tab's navigator
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final NavigatorState? currentNavigator = _navigatorKeys[_selectedIndex].currentState;
        if (currentNavigator != null && currentNavigator.canPop()) {
          currentNavigator.pop();
        } else {
          // If we can't pop anymore in the current tab, we could either:
          // 1. Exit the app (default behavior if we allow pop)
          // 2. Switch to the first tab (e.g., Orders)
          // For now, let's allow it to exit the app if we're on the first tab and it can't pop
          if (_selectedIndex != 0) {
            setState(() => _selectedIndex = 0);
          } else {
            // Re-invoke pop if we're on the very first screen of the first tab
             Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildTabNavigator(0, const ProviderOrdersScreen()),
            _buildTabNavigator(1, const ProviderCalendarScreen()),
            _buildTabNavigator(2, const ProviderOverviewScreen()),
            _buildTabNavigator(3, const ProviderMessageScreen()),
            _buildTabNavigator(4, const ProviderMenuScreen()),
          ],
        ),
        bottomNavigationBar: ProviderCustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemSelected: _onItemSelected,
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
}
