import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/provider/screen/provider_edit_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/provider/provider_profile_controller.dart';
import 'package:photopia/core/widgets/custom_network_image.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderProfileController>(
      builder: (context, profileController, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
          children: [
                _buildHeader(profileController),
                SizedBox(height: 100.h),
                _buildBody(profileController),
              ],
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
        // Header Image
        CustomNetworkImage(
          width: double.infinity,
          height: 300.h,
          imageUrl: 'assets/images/img5.png',
          fit: BoxFit.cover,
        ),
        // Gradient Overlay
        Container(
          height: 200.h,
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
        
        // Edit Button (Stylized top right)
        Positioned(
          top: 50.h,
          right: 20.w,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProviderEditProfileScreen(),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
        ),

        // Back Button
        Positioned(
          top: 50.h,
          left: 20.w,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
            ),
          ),
        ),

        // Floating Glassmorphism Profile Card
        Positioned(
          bottom: -5.h,
          left: 6.w,
          right: 6.w,
          child: _buildProfileCard(controller),
        ),

        // Overlapping Stats Row
        Positioned(
          bottom: -80.h,
          left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: _buildStatsRow(),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(ProviderProfileController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.01),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 75.r,
                    height: 75.r,
                    padding: EdgeInsets.all(2.5.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5.w),
                    ),
                    child: CustomNetworkImage(
                      imageUrl: 'assets/images/img6.png',
                      shape: BoxShape.circle,
                      fit: BoxFit.cover,
                    ),
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
                          'Wedding & Event Photography',
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
                              Icon(Icons.stars, color: Colors.white, size: 12.sp),
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

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(Icons.star_border, '4.9', 'Rating'),
        _buildStatItem(Icons.verified_outlined, '127', 'Reviews'),
        _buildStatItem(Icons.military_tech_outlined, '95%', 'Response Rate'),
        _buildStatItem(Icons.camera_alt_outlined, '342', 'Projects'),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Container(
      width: 78.w,
      height: 90.h,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10).r,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(icon, size: 22.sp, color: Colors.black87),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppTypography.h1,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[600],
                height: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
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
        Text('About Me', style: TextStyle(fontSize: AppTypography.h2, fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        Text(
          controller.aboutMe,
          style: TextStyle(fontSize: AppTypography.bodyLarge, color: Colors.black87, height: 1.5),
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
            Text('Specializations', style: TextStyle(fontSize: AppTypography.h2, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: controller.specializations.map((spec) => _buildChip(spec)).toList(),
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
            Text('Languages', style: TextStyle(fontSize: AppTypography.h2, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: controller.languages.map((lang) => _buildChip(lang)).toList(),
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
      child: Text(label, style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.black87)),
    );
  }

  Widget _buildRecentSection(ProviderProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent (${controller.recentWork.length})', style: TextStyle(fontSize: AppTypography.h2, fontWeight: FontWeight.bold)),
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
            Text('Client Reviews', style: TextStyle(fontSize: AppTypography.h2, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16.sp),
                SizedBox(width: 4.w),
                Text('4.9 (127 reviews)', style: TextStyle(fontSize: AppTypography.bodySmall, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),
        _buildReviewItem('Sarah Johnson', 'Nov 28, 2024', 'Emma was absolutely amazing! She captured every special moment of our wedding perfectly.'),
        SizedBox(height: 20.h),
        _buildReviewItem('Michael Chen', 'Nov 15, 2024', 'Professional, creative, and easy to work with. Highly recommend!'),
        SizedBox(height: 20.h),
        Center(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text('View All Reviews', textAlign: TextAlign.center, style: TextStyle(fontSize: AppTypography.bodyLarge, fontWeight: FontWeight.w500)),
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
                    child: Text(name, style: TextStyle(fontSize: AppTypography.bodyLarge, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: 8.w),
                  Text(date, style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey)),
                ],
              ),
              Row(
                children: List.generate(5, (_) => Icon(Icons.star, color: Colors.amber, size: 12.sp)),
              ),
              SizedBox(height: 8.h),
              Text(content, style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.black87, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
