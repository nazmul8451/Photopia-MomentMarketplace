import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/client/widgets/service_card.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/favorites_controller.dart';

class ProviderProfileScreen extends StatefulWidget {
  final Map<String, dynamic> provider;

  const ProviderProfileScreen({super.key, required this.provider});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    // Simulate loading data
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Consumer<FavoritesController>(
            builder: (context, controller, child) {
              bool isFavorite = controller
                  .isProviderFavorite(widget.provider['name'] ?? '');
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.black,
                  size: 24.sp,
                ),
                onPressed: () {
                  controller.toggleFavoriteProvider(widget.provider);
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.outlined_flag, color: Colors.red, size: 24.sp),
            onPressed: () {},
          ),
          SizedBox(width: 10.w),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Header Image
                Container(
                  height: 260.h,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/img5.png',
                      ),
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
                  child: _buildProfileInfo(),
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
            ),
            
            // Padding for the overlapping stats cards
            SizedBox(height: 100.h),
            
            // TabBar and Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  _buildTabBar(),
                  SizedBox(height: 20.h),
                  _buildTabContent(),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
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
                  fontSize: 18.sp,
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5.w),
                      image: DecorationImage(
                        image: AssetImage(widget.provider['avatar'] ??
                            'assets/images/img6.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.provider['name'] ?? 'Emma Wilson',
                          style: TextStyle(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Wedding & Event Photography',
                          style: TextStyle(
                            fontSize: 13.sp,
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

  Widget _buildTabBar() {
    return Container(
      height: 35.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(30).r,
      ),
      child: TabBar(
        controller: _tabController,
        padding: EdgeInsets.all(4.w),
        onTap: (index) {
          setState(() {});
        },
        indicator: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(30).r,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF455A64),
        labelStyle: TextStyle(
          fontSize: 12.sp.clamp(11, 13),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.sp.clamp(11, 13),
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Portfolio'),
            ),
          ),
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Reviews (127)'),
            ),
          ),
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('About'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Container(
      key: ValueKey(_tabController.index),
      child: [
        _buildPortfolioContent(),
        _buildReviewsContent(),
        _buildAboutContent(),
      ][_tabController.index],
    );
  }

  Widget _buildPortfolioContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services Offered',
          style: TextStyle(
            fontSize: AppTypography.h2,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15.h),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15.h,
            crossAxisSpacing: 15.w,
            childAspectRatio: 0.55,
          ),
          itemCount: _isLoading ? 2 : 3,
          itemBuilder: (context, index) {
            if (_isLoading) return ServiceCardSkeleton();
            return ServiceCard(
              title: 'Romantic Wedding Photography',
              subtitle: 'Emma Wilson',
              imageUrl: 'assets/images/img2.png',
              rating: 4.9,
              reviews: 127,
              priceRange: '€800 - €2,500',
              tags: const ['Wedding', 'Outdoor'],
              isPremium: true,
            );
          },
        ),
        SizedBox(height: 30.h),
        Text(
          'Recent Work',
          style: TextStyle(
            fontSize: AppTypography.h2,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15.h),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            final images = [
              'assets/images/img1.png',
              'assets/images/img2.png',
              'assets/images/img3.png',
              'assets/images/img4.png',
              'assets/images/img5.png',
              'assets/images/img6.png',
              'assets/images/img7.jpg',
              'assets/images/img8.jpg',
            ];
            return ClipRRect(
              borderRadius: BorderRadius.circular(12).r,
              child: Image.asset(
                images[index % images.length],
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewsContent() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage: const AssetImage('assets/images/img7.jpg'),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sarah & Michael',
                          style: TextStyle(
                            fontSize: AppTypography.bodyLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Row(
                              children: List.generate(5, (i) => Icon(Icons.star, color: Colors.orange, size: 14.sp)),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '10/15/2024',
                              style: TextStyle(
                                fontSize: AppTypography.bodySmall,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Wedding Photography - Premium Package',
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Emma was absolutely amazing! She captured our wedding day perfectly. The photos are stunning and she made us feel so comfortable throughout the day. Highly recommend!',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  _buildReviewImage('assets/images/img1.png'),
                  SizedBox(width: 10.w),
                  _buildReviewImage('assets/images/img2.png'),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReviewImage(String url) {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12).r,
        image: DecorationImage(image: AssetImage(url), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildAboutContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Me',
          style: TextStyle(
            fontSize: AppTypography.bodyLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          "Professional wedding and event photographer with over 8 years of experience capturing life's most precious moments. I specialize in candid, emotional photography that tells your unique story. My approach combines artistic vision with journalistic documentation to create timeless images you'll treasure forever.",
          style: TextStyle(
            fontSize: AppTypography.bodyMedium,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        SizedBox(height: 15.h),
        Text(
          'Member since 2021',
          style: TextStyle(
            fontSize: AppTypography.bodySmall,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 30.h),
        Text(
          'Languages',
          style: TextStyle(
            fontSize: AppTypography.bodyLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 12.w,
          children: [
            _buildAboutChip('English'),
            _buildAboutChip('Spanish'),
            _buildAboutChip('Catalan'),
          ],
        ),
        SizedBox(height: 30.h),
        Text(
          'Specializations',
          style: TextStyle(
            fontSize: AppTypography.bodyLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 12.w,
          children: [
            _buildAboutChip('Wedding'),
            _buildAboutChip('Event'),
            _buildAboutChip('Portrait'),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppTypography.bodySmall,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
