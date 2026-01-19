import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProviderCustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const ProviderCustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemSelected(index),
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
