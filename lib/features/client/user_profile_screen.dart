import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/client/notification_screen.dart';
import 'package:photopia/features/common/mode_transition_screen.dart';
import 'package:photopia/core/routes/app_routes.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/log_out_controller.dart';
import 'package:photopia/controller/client/user_profile_controller.dart';
import 'package:photopia/controller/location_controller.dart';
import 'package:photopia/features/client/widgets/auth_profile_image.dart';

class UserProfileScreen extends StatefulWidget {
  static const String name = '/user_profile';
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProfileController>().getUserProfile();
    });
  }

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
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.black,
              size: 24.sp,
            ),
            onPressed: () {
              // Navigate to settings
            },
          ),
          SizedBox(width: 10.w),
        ],
      ),
      body: Consumer<UserProfileController>(
        builder: (context, controller, child) {
          if (controller.inProgress) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = controller.userProfile;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileCard(context, user),
                SizedBox(height: 20.h),
                _buildRecentOrders(),
                SizedBox(height: 20.h),
                _buildMenuSection(context),
                SizedBox(height: 30.h),
                _buildActionButtons(context),
                SizedBox(height: 100.h), // Spacing for bottom nav
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, user) {
    // Construct valid profile image URL from API format
    String? imageUrl = user?.profile;
    if (imageUrl != null && !imageUrl.startsWith('http')) {
      // Assuming a base URL needs to be prepended, typically something like Urls.baseUrl,
      // but if api structure just sends /images path, handle fallback or base domain logic here.
      // E.g 'https://api.example.com' + imageUrl
      // For now we check if it's usable directly or fallback
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 30.h),
      child: Column(
        children: [
          AuthProfileImage(imageUrl: imageUrl, size: 100.w),
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline, color: Colors.white, size: 14.sp),
          ),
          SizedBox(height: 15.h),
          Text(
            user?.fullName ?? 'Loading...',
            style: TextStyle(
              fontSize: AppTypography.h1,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            user?.email ?? 'Loading...',
            style: TextStyle(
              fontSize: AppTypography.bodyMedium,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Consumer<LocationController>(
            builder: (context, locationController, _) {
              final displayLocation = locationController.currentAddress != "Detecting location..." 
                  ? locationController.currentAddress 
                  : (user?.location?.isNotEmpty ?? false ? user!.location! : "Custom Location");
              
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(25),
                  borderRadius: BorderRadius.circular(15).r,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (locationController.isLoading)
                      SizedBox(
                        width: 12.w,
                        height: 12.w,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                      )
                    else 
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.blue,
                        size: 14.sp,
                      ),
                    SizedBox(width: 4.w),
                    Text(
                      displayLocation,
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(AppRoutes.view_profile);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10).r,
              ),
              child: Text(
                'View All',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: FontWeight.bold,
                ),
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
            _buildOrderItem(
              'Wedding Photography',
              'Emma Wilson',
              '2024-06-15',
              '€1,500',
              'Completed',
            ),
            const Divider(),
            _buildOrderItem(
              'Corporate Video',
              'Tech Media Studio',
              '2024-05-20',
              '€2,800',
              'Completed',
            ),
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

  Widget _buildOrderItem(
    String title,
    String provider,
    String date,
    String price,
    String status,
  ) {
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
                  color: Colors.green.withAlpha(25),
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

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20).r,
        ),
        child: Column(
          children: [
            _buildMenuItem(
              Icons.shopping_bag_outlined,
              'Order History',
              badge: '3',
            ),
            _buildMenuItem(
              Icons.notifications_none,
              'Notifications',
              badge: '5',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                );
              },
            ),
            _buildMenuItem(Icons.lock_outline, 'Privacy & Security'),
            _buildMenuItem(Icons.language, 'Language', value: 'English'),
            _buildMenuItem(Icons.settings_outlined, 'Settings', isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    String? badge,
    String? value,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
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
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      color: Colors.grey,
                    ),
                  ),
                SizedBox(width: 10.w),
                Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey),
              ],
            ),
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
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => const ModeTransitionScreen(
                    targetRole: 'professional',
                    targetRoute: AppRoutes.provider_bottom_navigation,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 55.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(15).r,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Switch to Professional',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Consumer<LogOutController>(
            builder: (context, logOutController, child) {
              return GestureDetector(
                onTap: logOutController.inProgress
                    ? null
                    : () async {
                        debugPrint('🚪 Logout initiated...');
                        // Attempt API logout
                        final result = await logOutController.logOut();

                        if (!result) {
                          debugPrint(
                              '⚠️ Server logout failed, but clearing local state anyway.');
                        }

                        // 2. ALWAYS clear local state and navigate to login
                        await AuthController.forceLogout();
                      },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15).r,
                    border: Border.all(color: Colors.red.withAlpha(25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (logOutController.inProgress)
                        SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            color: Colors.red,
                            strokeWidth: 2,
                          ),
                        )
                      else ...[
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
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
