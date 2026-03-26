import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/provider/screen/provider_edit_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/provider/provider_profile_controller.dart';
import 'package:photopia/core/widgets/custom_network_image.dart';
import 'package:photopia/features/client/widgets/auth_profile_image.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderProfileController>().getProviderProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderProfileController>(
      builder: (context, profileController, child) {
        if (profileController.inProgress && profileController.userProfile == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: RefreshIndicator(
            onRefresh: () => profileController.getProviderProfile(),
            color: Colors.black,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                children: [
                  _buildHeader(profileController),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        SizedBox(height: 100.h), // Spacing for the overlapping profile card
                        _buildViewPublicProfileButton(),
                        SizedBox(height: 20.h),
                        _buildStatsGrid(profileController),
                        SizedBox(height: 20.h),
                        _buildPremiumCard(profileController),
                        SizedBox(height: 30.h),
                        _buildBody(profileController),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ProviderProfileController controller) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Header Image (Background)
        CustomNetworkImage(
          width: double.infinity,
          height: 220.h,
          imageUrl: controller.userProfile?.profile ?? 'assets/images/img5.png',
          fit: BoxFit.cover,
        ),
        // Gradient Overlay
        Container(
          height: 220.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.1),
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
        ),

        // Floating Glassmorphism Profile Card
        Positioned(
          bottom: -80.h,
          left: 20.w,
          right: 20.w,
          child: _buildProfileCard(controller),
        ),
      ],
    );
  }

  Widget _buildProfileCard(ProviderProfileController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.black12.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Button (Stylized top right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: AppTypography.h1,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ProviderEditProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AuthProfileImage(
                    imageUrl: controller.profileImage,
                    size: 75.r,
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.name,
                          style: TextStyle(
                            fontSize: AppTypography.h1,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          controller.specialty,
                          style: TextStyle(
                            fontSize: AppTypography.bodyMedium,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30).r,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.stars,
                                color: Colors.white,
                                size: 12.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'Premium',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15.h),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewPublicProfileButton() {
    return Container(
      width: double.infinity,
      height: 54.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          'View Public Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ProviderProfileController controller) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDashboardCard(
                icon: Icons.calendar_today_outlined,
                title: 'Bookings',
                value: controller.bookingsCount.toString(),
                subtitle: '+${controller.bookingsThisWeek} this week',
                subtitleColor: Colors.blueAccent,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: _buildDashboardCard(
                icon: Icons.euro, // Updated to Euro to match screenshot
                title: 'Revenue',
                value: '€${_formatLargeNumber(controller.revenueAmount)}',
                subtitle: '+${controller.revenueChange}% vs last month',
                subtitleColor: Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Row(
          children: [
            Expanded(
              child: _buildDashboardCard(
                icon: Icons.trending_up,
                title: 'Profile Views',
                value: _formatLargeNumber(controller.profileViews.toDouble()),
                subtitle: 'this week', // API doesn't have weekly views % yet
                subtitleColor: Colors.grey,
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: _buildDashboardCard(
                icon: Icons.star_border,
                title: 'Rating',
                value: controller.rating.toStringAsFixed(1),
                subtitle: '${controller.reviewCount} reviews',
                subtitleColor: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.sp, color: Colors.grey[600]),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: subtitleColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(ProviderProfileController controller) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.stars, color: Colors.amber, size: 24.sp),
                  SizedBox(width: 10.w),
                  Text(
                    'Premium Member',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '€10/month',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Text(
            'Priority search placement • Extended analytics • Premium badge',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[800]!),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                'Manage Subscription',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLargeNumber(double number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toInt().toString();
  }

  Widget _buildBody(ProviderProfileController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAboutSection(controller),
          SizedBox(height: 25.h),
          _buildSpecializationsSection(controller),
          SizedBox(height: 25.h),
          _buildLanguagesSection(controller),
          SizedBox(height: 25.h),
          _buildRecentSection(controller),
          SizedBox(height: 25.h),
          _buildReviewsSection(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildAboutSection(ProviderProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Me',
          style: TextStyle(
            fontSize: AppTypography.h2,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          controller.aboutMe,
          style: TextStyle(
            fontSize: AppTypography.bodyLarge,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecializationsSection(ProviderProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Specializations',
              style: TextStyle(
                fontSize: AppTypography.h2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: controller.specializations
              .map((spec) => _buildChip(spec))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLanguagesSection(ProviderProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Languages',
              style: TextStyle(
                fontSize: AppTypography.h2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: controller.languages
              .map((lang) => _buildChip(lang))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppTypography.bodySmall,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildRecentSection(ProviderProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent (${controller.recentWork.length})',
              style: TextStyle(
                fontSize: AppTypography.h2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1,
          ),
          itemCount: controller.recentWork.length,
          itemBuilder: (context, index) {
            return CustomNetworkImage(
              imageUrl: controller.recentWork[index],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.circular(10.r),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Client Reviews',
              style: TextStyle(
                fontSize: AppTypography.h2,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16.sp),
                SizedBox(width: 4.w),
                Text(
                  '4.9 (127 reviews)',
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),
        _buildReviewItem(
          'Sarah Johnson',
          'Nov 28, 2024',
          'Emma was absolutely amazing! She captured every special moment of our wedding perfectly.',
        ),
        SizedBox(height: 20.h),
        _buildReviewItem(
          'Michael Chen',
          'Nov 15, 2024',
          'Professional, creative, and easy to work with. Highly recommend!',
        ),
        SizedBox(height: 20.h),
        Center(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              'View All Reviews',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTypography.bodyLarge,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String name, String date, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomNetworkImage(
          width: 40.r,
          height: 40.r,
          shape: BoxShape.circle,
          imageUrl: 'assets/images/img7.jpg',
          fit: BoxFit.cover,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: AppTypography.bodyLarge,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Row(
                children: List.generate(
                  5,
                  (_) => Icon(Icons.star, color: Colors.amber, size: 12.sp),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                content,
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
