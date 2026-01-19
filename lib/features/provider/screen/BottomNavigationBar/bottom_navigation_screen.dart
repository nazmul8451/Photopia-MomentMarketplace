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

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const ProviderOrdersScreen(),
    const ProviderCalendarScreen(),
    const ProviderOverviewScreen(),
    const ProviderMessageScreen(),
    const ProviderMenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: ProviderCustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
