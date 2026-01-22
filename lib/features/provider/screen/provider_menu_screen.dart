import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/common/mode_transition_screen.dart';
import 'package:photopia/core/routes/app_routes.dart';
import 'package:photopia/features/provider/screen/provider_subscription_screen.dart';
import 'package:photopia/features/provider/screen/provider_profile_screen.dart';
import 'package:photopia/features/provider/screen/provider_wallet_screen.dart';
import 'package:photopia/core/widgets/custom_network_image.dart';

class ProviderMenuScreen extends StatelessWidget {
  const ProviderMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Profile Section
                _buildProfileSection(context),
                SizedBox(height: 16.h.clamp(12, 20)),
                
                // Stats Grid
                _buildStatsGrid(),
                SizedBox(height: 16.h.clamp(12, 20)),
                
                // Premium Member Card
                _buildPremiumCard(context),
                SizedBox(height: 16.h.clamp(12, 20)),
                
                // Menu Items
                _buildMenuItem(
                  icon: Icons.payment,
                  title: 'Payments & Transactions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProviderWalletScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12.h.clamp(8, 16)),
                
                _buildMenuItem(
                  icon: Icons.bar_chart,
                  title: 'Detailed Statistics',
                  isPremium: true,
                  onTap: () {},
                ),
                SizedBox(height: 12.h.clamp(8, 16)),
                
                _buildMenuItem(
                  icon: Icons.settings,
                  title: 'Account Settings',
                  onTap: () {},
                ),
                SizedBox(height: 12.h.clamp(8, 16)),
                
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  hasNotification: true,
                  onTap: () {},
                ),
                SizedBox(height: 12.h.clamp(8, 16)),
                
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {},
                ),
                SizedBox(height: 24.h.clamp(20, 28)),
                
                // Switch to Client Button
                _buildSwitchButton(context),
                SizedBox(height: 12.h.clamp(8, 16)),
                
                // Sign Out Button
                _buildSignOutButton(),
                SizedBox(height: 16.h.clamp(12, 20)),
                
                // App Version
                Text(
                  'Photopia Pro v1.0.4',
                  style: TextStyle(
                    fontSize: 12.sp.clamp(11, 13),
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Image - Larger and Circular
              Container(
                width: 60.w.clamp(55, 65),
                height: 60.w.clamp(55, 65),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: CustomNetworkImage(
                  imageUrl: 'assets/images/img8.jpg',
                  shape: BoxShape.circle,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Michael Photographer',
                      style: TextStyle(
                        fontSize: 17.sp.clamp(16, 18),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Professional Photographer',
                      style: TextStyle(
                        fontSize: 13.sp.clamp(12, 14),
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '👑',
                            style: TextStyle(fontSize: 10.sp),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Premium',
                            style: TextStyle(
                              fontSize: 11.sp.clamp(10, 12),
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h.clamp(12, 16)),
          SizedBox(
            width: double.infinity,
            height: 48.h.clamp(44, 52),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProviderProfileScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'View Public Profile',
                style: TextStyle(
                  fontSize: 15.sp.clamp(14, 16),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today,
                label: 'Bookings',
                value: '12',
                subtitle: '+3 this week',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                icon: Icons.euro,
                label: 'Revenue',
                value: '€8.4K',
                subtitle: '+15% vs last month',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h.clamp(10, 14)),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                label: 'Profile Views',
                value: '1.2K',
                subtitle: '+8% this week',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStatCard(
                icon: Icons.star,
                label: 'Rating',
                value: '4.9',
                subtitle: '127 reviews',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp.clamp(14, 18), color: Colors.grey[600]),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp.clamp(11, 13),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h.clamp(6, 10)),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp.clamp(18, 22),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.sp.clamp(10, 12),
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.amber, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Premium Member',
                style: TextStyle(
                  fontSize: 14.sp.clamp(13, 15),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '€10/month',
                style: TextStyle(
                  fontSize: 13.sp.clamp(12, 14),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h.clamp(10, 14)),
          Text(
            'Priority search placement • Extended analytics • Premium badge',
            style: TextStyle(
              fontSize: 12.sp.clamp(11, 13),
              color: Colors.grey[400],
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h.clamp(10, 14)),
            SizedBox(
            width: double.infinity,
            height: 48.h.clamp(44, 52),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProviderSubscriptionScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Manage Subscription',
                style: TextStyle(
                  fontSize: 13.sp.clamp(12, 14),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isPremium = false,
    bool hasNotification = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 22.sp.clamp(20, 24), color: Colors.black),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp.clamp(13, 15),
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            if (isPremium)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '👑 Premium',
                  style: TextStyle(
                    fontSize: 10.sp.clamp(9, 11),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (hasNotification)
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp.clamp(12, 16),
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h.clamp(44, 52),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => const ModeTransitionScreen(
                targetRole: 'client',
                targetRoute: AppRoutes.bottom_navigation,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        icon: Icon(Icons.camera_alt, size: 20.sp.clamp(18, 22), color: Colors.white),
        label: Text(
          'Switch to Client',
          style: TextStyle(
            fontSize: 15.sp.clamp(14, 16),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h.clamp(44, 52),
      child: OutlinedButton.icon(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        icon: Icon(Icons.logout, size: 20.sp.clamp(18, 22), color: Colors.red),
        label: Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 15.sp.clamp(14, 16),
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
