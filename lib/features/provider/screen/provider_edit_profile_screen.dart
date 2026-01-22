import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:photopia/controller/provider/provider_profile_controller.dart';
import 'package:photopia/core/widgets/custom_network_image.dart';

class ProviderEditProfileScreen extends StatefulWidget {
  const ProviderEditProfileScreen({super.key});

  @override
  State<ProviderEditProfileScreen> createState() => _ProviderEditProfileScreenState();
}

class _ProviderEditProfileScreenState extends State<ProviderEditProfileScreen> {
  late TextEditingController _aboutController;
  late List<String> _tempSpecializations;
  late List<String> _tempLanguages;
  late List<String> _tempRecentWork;

  @override
  void initState() {
    super.initState();
    final controller = context.read<ProviderProfileController>();
    _aboutController = TextEditingController(text: controller.aboutMe);
    _tempSpecializations = List.from(controller.specializations);
    _tempLanguages = List.from(controller.languages);
    _tempRecentWork = List.from(controller.recentWork);
  }

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    context.read<ProviderProfileController>().updateProfile(
      aboutMe: _aboutController.text,
      specializations: _tempSpecializations,
      languages: _tempLanguages,
      recentWork: _tempRecentWork,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 100.h),
            _buildEditBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          Container(
            width: double.infinity,
            height: 300.h,
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 40.sp),
            ),
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
        
        // Navigation Back Button (on top of cover photo)
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
          child: _buildProfileCard(),
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

  Widget _buildProfileCard() {
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
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20.sp),
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: _saveChanges,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4C6A5A).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.check_circle_outline, color: Colors.white, size: 20.sp),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
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
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_alt, color: Colors.black, size: 12.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Michael Photographer',
                          style: TextStyle(
                            fontSize: AppTypography.h1,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTypography.bodySmall,
              color: Colors.grey[600],
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditBody() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About Me', style: TextStyle(fontSize: AppTypography.h2, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: TextField(
              controller: _aboutController,
              maxLines: 4,
              style: TextStyle(fontSize: AppTypography.bodyLarge, color: Colors.black87),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12.w),
              ),
            ),
          ),
          SizedBox(height: 25.h),
          
          _buildEditableSection('Specializations', _tempSpecializations, (value) {
            setState(() {
              _tempSpecializations.add(value);
            });
          }, (value) {
            setState(() {
              _tempSpecializations.remove(value);
            });
          }),
          SizedBox(height: 25.h),
          
          _buildEditableSection('Languages', _tempLanguages, (value) {
             setState(() {
              _tempLanguages.add(value);
            });
          }, (value) {
             setState(() {
              _tempLanguages.remove(value);
            });
          }),
          SizedBox(height: 25.h),
          
          _buildGallerySection(),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildEditableSection(String title, List<String> items, Function(String) onAdd, Function(String) onRemove) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: AppTypography.h2, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => _showAddDialog(title, onAdd),
              child: Icon(Icons.add, size: 22.sp, color: Colors.black)
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: items.map((item) => _buildEditChip(item, () => onRemove(item))).toList(),
        ),
      ],
    );
  }

  void _showAddDialog(String title, Function(String) onAdd) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onAdd(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditChip(String label, VoidCallback onRemove) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.black87)),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14.sp, color: Colors.black54)
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent (${_tempRecentWork.length})', style: TextStyle(fontSize: AppTypography.h2, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () {
                // Mock adding a photo
                setState(() {
                  _tempRecentWork.add('assets/images/img1.png');
                });
              },
              child: Row(
                children: [
                  Icon(Icons.add, size: 14.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text('Add Photo', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                ],
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
          itemCount: _tempRecentWork.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                CustomNetworkImage(
                  imageUrl: _tempRecentWork[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _tempRecentWork.removeAt(index);
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 10.sp),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
