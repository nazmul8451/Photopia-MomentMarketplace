import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/controller/client/user_profile_controller.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/core/routes/app_routes.dart';
import 'package:photopia/features/client/widgets/auth_profile_image.dart';
import 'package:provider/provider.dart';

class ViewProfileScreen extends StatelessWidget {
  static const String name = '/view_profile';
  const ViewProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'View Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp.clamp(20, 22),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.edit_profile);
              },
              child: Text(
                'Edit',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<UserProfileController>(
        builder: (context, controller, _) {
          final user = controller.userProfile;
          if (user == null) {
            return const Center(child: Text("No Profile Data"));
          }
          final String? imageUrl = user.profile;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                AuthProfileImage(imageUrl: imageUrl, size: 120.w),
                SizedBox(height: 30.h),
                _buildInfoTile(
                  Icons.person_outline,
                  'Name',
                  user.fullName ?? 'Not Set',
                ),
                _buildInfoTile(
                  Icons.email_outlined,
                  'Email',
                  user.email ?? 'Not Set',
                ),
                _buildInfoTile(
                  Icons.phone_outlined,
                  'Phone Number',
                  user.phone ?? 'Not Set',
                ),
                _buildInfoTile(
                  Icons.location_on_outlined,
                  'Location',
                  user.location ?? 'Not Set',
                ),
                _buildInfoTile(
                  Icons.work_outline,
                  'Role',
                  user.role?.toUpperCase() ?? 'USER',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15).r,
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue, size: 24.sp),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: AppTypography.bodyLarge,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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
