import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/provider/screen/provider_orders_screen.dart';
import 'package:photopia/features/provider/screen/provider_calendar_screen.dart';
import 'package:photopia/features/provider/screen/provider_overview_screen.dart';
import 'package:photopia/features/provider/screen/provider_message_screen.dart';
import 'package:photopia/features/provider/screen/provider_menu_screen.dart';

class ProviderBottomNavigationScreen extends StatefulWidget {
  const ProviderBottomNavigationScreen({super.key});
  static const String name = "/provider-bottom-navigation";

  @override
  State<ProviderBottomNavigationScreen> createState() => _ProviderBottomNavigationScreenState();
}

class _ProviderBottomNavigationScreenState extends State<ProviderBottomNavigationScreen> {
  int _selectedIndex = 0;

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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 8.h.clamp(6, 10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.bookmark_border,
                  label: 'Orders',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Calendar',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.description_outlined,
                  label: 'Overview',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.chat_bubble_outline,
                  label: 'Massage',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.menu,
                  label: 'Menu',
                  index: 4,
                ),
              ],
            ),
          ),
    
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4.h.clamp(3, 6)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22.sp.clamp(20, 24),
                color: isSelected ? Colors.black : Colors.grey,
              ),
              SizedBox(height: 4.h.clamp(3, 5)),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp.clamp(10, 12),
                  color: isSelected ? Colors.black : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
