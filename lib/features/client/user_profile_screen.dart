import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/common/mode_transition_screen.dart';
import 'package:photopia/core/routes/app_routes.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp.clamp(20, 22),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.black, size: 24.sp),
            onPressed: () {},
          ),
          SizedBox(width: 10.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileCard(),
            SizedBox(height: 20.h),
            _buildRecentOrders(),
            SizedBox(height: 20.h),
            _buildMenuSection(),
            SizedBox(height: 30.h),
            _buildActionButtons(context),
            SizedBox(height: 100.h), // Spacing for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_outline, color: Colors.white, size: 14.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Text(
            'John Doe',
            style: TextStyle(
              fontSize: AppTypography.h1,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'john.doe@email.com',
            style: TextStyle(
              fontSize: AppTypography.bodyMedium,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: Colors.red, size: 14.sp),
              SizedBox(width: 4.w),
              Text(
                'Barcelona, Spain',
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10).r,
            ),
            child: Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: AppTypography.bodyMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20).r,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: AppTypography.h2,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15.h),
            _buildOrderItem('Wedding Photography', 'Emma Wilson', '2024-06-15', '€1,500', 'Completed'),
            const Divider(),
            _buildOrderItem('Corporate Video', 'Tech Media Studio', '2024-05-20', '€2,800', 'Completed'),
            SizedBox(height: 15.h),
            Center(
              child: Text(
                'View All Orders',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(String title, String provider, String date, String price, String status) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppTypography.bodyLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                provider,
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  color: Colors.grey,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5).r,
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10.sp.clamp(10, 11),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                price,
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20).r,
        ),
        child: Column(
          children: [
            _buildMenuItem(Icons.shopping_bag_outlined, 'Order History', badge: '3'),
            _buildMenuItem(Icons.notifications_none, 'Notifications', badge: '5'),
            _buildMenuItem(Icons.lock_outline, 'Privacy & Security'),
            _buildMenuItem(Icons.language, 'Language', value: 'English'),
            _buildMenuItem(Icons.settings_outlined, 'Settings', isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? badge, String? value, bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
          child: Row(
            children: [
              Icon(icon, size: 24.sp, color: Colors.black),
              SizedBox(width: 15.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppTypography.bodyLarge,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(color: Colors.white, fontSize: 10.sp),
                  ),
                ),
              if (value != null)
                Text(
                  value,
                  style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.grey),
                ),
              SizedBox(width: 10.w),
              Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 50),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ModeTransitionScreen(
                    targetRole: 'provider',
                    targetRoute: AppRoutes.provider_bottom_navigation,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(15).r,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20.sp),
                  SizedBox(width: 10.w),
                  Text(
                    'Switch to Professional',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 15.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15).r,
              border: Border.all(color: Colors.red.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.red, size: 20.sp),
                SizedBox(width: 10.w),
                Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: AppTypography.bodyLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
