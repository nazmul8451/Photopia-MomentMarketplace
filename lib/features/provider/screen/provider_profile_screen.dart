import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:photopia/controller/provider/provider_profile_controller.dart';
import 'package:photopia/core/widgets/custom_network_image.dart';
import 'package:photopia/features/client/widgets/auth_profile_image.dart';
import 'package:photopia/core/widgets/custom_snacbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  File? _coverPhoto;
  File? _profilePhoto;
  
  // Temporary state for in-place editing
  List<String> _tempSpecializations = [];
  List<String> _tempLanguages = [];
  List<dynamic> _tempPortfolio = [];

  // Tracking deletions for the /remove-items API
  final Set<String> _removedSpecializations = {};
  final Set<String> _removedLanguages = {};
  final Set<String> _removedPortfolio = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  void _loadProfileData() {
    context.read<ProviderProfileController>().getProviderProfile().then((success) {
      if (success && mounted) {
        final ctrl = context.read<ProviderProfileController>();
        _aboutController.text = ctrl.aboutMe;
        _bioController.text = ctrl.shortBio;
        _nameController.text = ctrl.name;
        _tempSpecializations = List<String>.from(ctrl.specializations);
        _tempLanguages = List<String>.from(ctrl.languages);
        _tempPortfolio = List<dynamic>.from(ctrl.recentWork);
        _profilePhoto = null;
        _coverPhoto = null;
        setState(() {});

        // Fetch reviews using the provider's ID
        final providerId = ctrl.professionalProfile?.user?.id ?? ctrl.userProfile?.id;
        if (providerId != null) {
          ctrl.getProviderReviews(providerId);
        }
      }
    });
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _bioController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final controller = context.read<ProviderProfileController>();
    
    setState(() {
      _isEditing = false;
      _isSaving = true;
    });
    
    // 1. Handle explicit removals first using the new API
    bool removalSuccess = true;
    
    if (_removedSpecializations.isNotEmpty) {
       for (var item in _removedSpecializations) {
         if (!await controller.removeItemFromProfessionalProfile(field: 'specialties', value: item)) removalSuccess = false;
       }
    }
    if (_removedLanguages.isNotEmpty) {
       for (var item in _removedLanguages) {
         if (!await controller.removeItemFromProfessionalProfile(field: 'language', value: item)) removalSuccess = false;
       }
    }
    if (_removedPortfolio.isNotEmpty) {
       for (var item in _removedPortfolio) {
         if (!await controller.removeItemFromProfessionalProfile(field: 'portfolio', value: item)) removalSuccess = false;
       }
    }

    if (!removalSuccess) {
      setState(() {
         _isSaving = false;
         _isEditing = true;
      });
      if (mounted) {
        CustomSnackBar.show(
          context: context, 
          message: 'Some items failed to delete: ${controller.errorMessage}', 
          isError: true
        );
      }
      return; 
    }

    // 2. Calculate New Additions (to avoid duplication since backend appends)
    final List<String> newSpecializations = _tempSpecializations.where((s) => !controller.specializations.contains(s)).toList();
    final List<String> newLanguages = _tempLanguages.where((l) => !controller.languages.contains(l)).toList();
    final List<File> newPortfolioFiles = _tempPortfolio.whereType<File>().toList();

    // 3. Perform main update (only new additions and text changes)
    final success = await controller.updateProviderProfile(
      name: _nameController.text != controller.name ? _nameController.text : null,
      bio: _bioController.text != controller.shortBio ? _bioController.text : null,
      description: _aboutController.text != controller.aboutMe ? _aboutController.text : null,
      newSpecializations: newSpecializations,
      newLanguages: newLanguages,
      newPortfolioFiles: newPortfolioFiles,
      profilePhoto: _profilePhoto,
      coverPhoto: _coverPhoto,
    );

    setState(() => _isSaving = false);

    if (success) {
      if (mounted) {
        // Clear removal trackers
        _removedSpecializations.clear();
        _removedLanguages.clear();
        _removedPortfolio.clear();
        
        // Reload from fresh API data
        _aboutController.text = controller.aboutMe;
        _bioController.text = controller.shortBio;
        _nameController.text = controller.name;
        _tempSpecializations = List<String>.from(controller.specializations);
        _tempLanguages = List<String>.from(controller.languages);
        _tempPortfolio = List<dynamic>.from(controller.recentWork);
        setState(() {});
        
        CustomSnackBar.show(
          context: context, 
          message: 'Profile updated successfully', 
          isError: false
        );
      }
    } else {
      setState(() => _isEditing = true);
      if (mounted) {
        CustomSnackBar.show(
          context: context, 
          message: controller.errorMessage ?? 'Update failed', 
          isError: true
        );
      }
    }
  }

  Future<void> _pickPortfolioImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (image != null) {
      setState(() {
        _tempPortfolio.add(File(image.path));
      });
    }
  }

  Future<void> _pickProfilePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 500,
      maxHeight: 500,
    );
    if (image != null) {
      setState(() {
        _profilePhoto = File(image.path);
      });
    }
  }

  Future<void> _pickCoverPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1200,
      maxHeight: 800,
    );
    if (image != null) {
      setState(() {
        _coverPhoto = File(image.path);
      });
    }
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
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (_isEditing)
                IconButton(
                  icon: Icon(Icons.camera_alt_outlined, color: Colors.black, size: 24.sp),
                  onPressed: _pickCoverPhoto,
                ),
              SizedBox(width: 10.w),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => _loadProfileData(),
            color: Colors.black,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header Stack with Card + Stats overlapping
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Header Image
                      Container(
                        height: 220.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: _coverPhoto != null
                                ? FileImage(_coverPhoto!) as ImageProvider
                                : (profileController.coverPhoto != null 
                                   ? NetworkImage(profileController.coverPhoto!) as ImageProvider
                                   : const AssetImage('assets/images/img5.png')),
                            fit: BoxFit.cover,
                          ),
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

                      // Floating Glassmorphism Profile Card
                      Positioned(
                        bottom: -5.h,
                        left: 6.w,
                        right: 6.w,
                        child: _buildProfileCard(profileController),
                      ),

                      // Overlapping Stats Row
                      Positioned(
                        bottom: -80.h,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: _buildStatsRow(profileController),
                        ),
                      ),
                    ],
                  ),

                  // Padding for the overlapping stats cards
                  SizedBox(height: 100.h),

                  // Content below
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAboutSection(),
                        SizedBox(height: 25.h),
                        _buildChipsSection('Specializations', true),
                        SizedBox(height: 25.h),
                        _buildChipsSection('Languages', false),
                        SizedBox(height: 25.h),
                        _buildRecentWorkSection(),
                        SizedBox(height: 25.h),
                        _buildReviewsSection(profileController),
                        SizedBox(height: 40.h),
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
              // "Profile" title + Edit button row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  if (!_isEditing && !_isSaving)
                    GestureDetector(
                      onTap: () => setState(() => _isEditing = true),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Icon(Icons.edit_outlined, color: Colors.white, size: 20.sp),
                      ),
                    )
                  else if (_isSaving)
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: SizedBox(
                        width: 20.sp,
                        height: 20.sp,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _saveChanges,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.check, color: Colors.white, size: 20.sp),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              // Avatar + Name/Specialty/Badge row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 75.r,
                        height: 75.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5.w),
                        ),
                        child: ClipOval(
                          child: _profilePhoto != null 
                              ? Image.file(_profilePhoto!, fit: BoxFit.cover, width: 75.r, height: 75.r)
                              : AuthProfileImage(
                                  imageUrl: controller.profileImage,
                                  size: 75.r,
                                ),
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickProfilePhoto,
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.camera_alt, size: 14.sp, color: Colors.black),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isEditing) ...[
                          TextFormField(
                            controller: _nameController,
                            style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Full Name',
                              hintStyle: TextStyle(color: Colors.white60, fontSize: 16.sp),
                              isCollapsed: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          TextFormField(
                            controller: _bioController,
                            style: TextStyle(fontSize: 12.5.sp, color: Colors.white.withOpacity(0.8)),
                            decoration: InputDecoration(
                              hintText: 'Bio Tagline (e.g. Wedding Photographer)',
                              hintStyle: TextStyle(color: Colors.white60, fontSize: 13.sp),
                              isCollapsed: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                            ),
                          ),
                        ] else ...[
                          Text(
                            controller.name,
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (controller.shortBio.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              controller.shortBio,
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                        SizedBox(height: 10.h),
                        if (controller.userProfile?.isSubscribed ?? false)
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
                          )
                        else
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(30).r,
                            ),
                            child: Text(
                              'Free Member',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        SizedBox(height: 5.h),
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

  Widget _buildStatsRow(ProviderProfileController controller) {
    final rating = controller.rating.toStringAsFixed(1);
    final reviews = controller.reviewCount.toString();
    final responseRate = '${controller.responseRate}%';
    final projectsCount = controller.projectsCount.toString();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(Icons.star_border, rating, 'Rating'),
        _buildStatItem(Icons.verified_outlined, reviews, 'Reviews'),
        _buildStatItem(Icons.military_tech_outlined, responseRate, 'Response\nRate'),
        _buildStatItem(Icons.camera_alt_outlined, projectsCount, 'Projects'),
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
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[600],
              height: 1,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Me',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        if (_isEditing)
          TextFormField(
            controller: _aboutController,
            maxLines: null,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF5F5F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          )
        else
          Text(
            _aboutController.text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
      ],
    );
  }

  Widget _buildChipsSection(String title, bool isSpecialty) {
    final List<String> list = isSpecialty ? _tempSpecializations : _tempLanguages;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            if (_isEditing)
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Colors.blueAccent, size: 22.sp),
                onPressed: () => _showAddChipDialog(title, isSpecialty),
              ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: list.map((item) => _buildChip(item, isSpecialty)).toList(),
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isSpecialty) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20).r,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.black87),
          ),
          if (_isEditing) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isSpecialty) {
                    final item = label;
                    _tempSpecializations.remove(item);
                    _removedSpecializations.add(item);
                  } else {
                    final item = label;
                    _tempLanguages.remove(item);
                    _removedLanguages.add(item);
                  }
                });
              },
              child: Icon(Icons.close, size: 14.sp, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentWorkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Portfolio (${_tempPortfolio.length})',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            if (_isEditing)
              GestureDetector(
                onTap: _pickPortfolioImage,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: Colors.white, size: 16.sp),
                      SizedBox(width: 6.w),
                      Text(
                        'Add Photo',
                        style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
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
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 1,
          ),
          itemCount: _tempPortfolio.length,
          itemBuilder: (context, index) {
            final item = _tempPortfolio[index];
            return Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10).r,
                    child: item is File
                        ? Image.file(item, fit: BoxFit.cover)
                        : CustomNetworkImage(imageUrl: item.toString(), fit: BoxFit.cover),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          final removedItem = _tempPortfolio.removeAt(index);
                          if (removedItem is String) {
                            _removedPortfolio.add(removedItem);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
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

  Widget _buildReviewsSection(ProviderProfileController controller) {
    if (controller.inProgress && controller.reviews.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }
    
    final reviews = controller.reviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Client Reviews',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16.sp),
                SizedBox(width: 4.w),
                Text(
                  '${controller.rating.toStringAsFixed(1)} (${controller.reviewCount} reviews)',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20.h),
        if (reviews.isEmpty)
          Container(
            padding: EdgeInsets.symmetric(vertical: 30.h),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7).withOpacity(0.5),
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Column(
              children: [
                Icon(Icons.rate_review_outlined, color: Colors.grey[400], size: 40.sp),
                SizedBox(height: 12.h),
                Text(
                  'No reviews yet',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Completed bookings will appear here',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length > 3 ? 3 : reviews.length, // Limit preview
            separatorBuilder: (context, index) => SizedBox(height: 20.h),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return _buildReviewItem(
                review.user?.name ?? 'Anonymous',
                review.createdAt ?? '',
                review.comment ?? '',
                review.rating?.toDouble() ?? 5.0,
              );
            },
          ),
      ],
    );
  }

  Widget _buildReviewItem(String name, String date, String comment, double rating) {
    // Format date string (e.g., 2024-11-28T... -> Nov 28, 2024)
    String formattedDate = date;
    try {
      if (date.isNotEmpty) {
        final dt = DateTime.parse(date);
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        formattedDate = "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
      }
    } catch (_) {}

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.person, color: Colors.grey[400], size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: List.generate(5, (index) => Icon(
                        Icons.star, 
                        color: index < rating ? Colors.amber : Colors.grey[300], 
                        size: 12.sp
                      )),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              formattedDate,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.only(left: 48.w),
          child: Text(
            comment,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddChipDialog(String title, bool isSpecialty) {
    final TextEditingController chipController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add $title',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Enter the ${title.toLowerCase()} you want to add to your profile.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: chipController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. ${isSpecialty ? "Portrait Photography" : "English"}',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F7),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                style: TextStyle(fontSize: 15.sp),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12).r),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12).r),
                      ),
                      onPressed: () {
                        if (chipController.text.trim().isNotEmpty) {
                          setState(() {
                            if (isSpecialty) {
                              _tempSpecializations.add(chipController.text.trim());
                            } else {
                              _tempLanguages.add(chipController.text.trim());
                            }
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        'Add',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                      ),
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
}
