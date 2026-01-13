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

class _ProviderProfileScreenState extends State<ProviderProfileScreen> with SingleTickerProviderStateMixin {
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
      body: Stack(
        children: [
          // Background Header Image
          Container(
            height: 250.h,
            width: double.infinity,
            child: Image.network(
              'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?q=80&w=1000',
              fit: BoxFit.cover,
            ),
          ),
          // Scrollable Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top App Bar
                SliverAppBar(
                  expandedHeight: 320.h,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: EdgeInsets.only(top: 80.h),
                      child: _isLoading ? ProfileHeaderSkeleton() : _buildProfileInfo(),
                    ),
                  ),
                  leading: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    Consumer<FavoritesController>(
                      builder: (context, controller, child) {
                        bool isFavorite = controller.isProviderFavorite(widget.provider['name'] ?? '');
                        return IconButton(
                          icon: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite ? Icons.bookmark : Icons.bookmark_outline,
                              color: isFavorite ? Colors.black : Colors.black,
                              size: 20.sp,
                            ),
                          ),
                          onPressed: () {
                            controller.toggleFavoriteProvider(widget.provider);
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.flag, color: Colors.red, size: 20.sp),
                      ),
                      onPressed: () {},
                    ),
                    SizedBox(width: 10.w),
                  ],
                ),
                // Profile Header Card
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatsRow(),
                          _buildTabBar(),
                          SizedBox(height: 20.h),
                          _buildTabContent(),
                          SizedBox(height: 100.h), // Bottom nav padding
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.w, top: 10.h),
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 22.sp.clamp(22, 24),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 15.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20).r,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20).r,
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                        image: DecorationImage(
                          image: NetworkImage(widget.provider['avatar'] ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.provider['name'] ?? 'Emma Wilson',
                            style: TextStyle(
                              fontSize: AppTypography.h1,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Wedding & Event Photography',
                            style: TextStyle(
                              fontSize: AppTypography.bodySmall,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20).r,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.stars, color: Colors.orange, size: 12.sp),
                                SizedBox(width: 4.w),
                                Text(
                                  'Premium',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp.clamp(10, 11),
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
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Transform.translate(
      offset: Offset(0, -30.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(Icons.star_outline, '4.9', 'Rating'),
          _buildStatItem(Icons.check_circle_outline, '127', 'Reviews'),
          _buildStatItem(Icons.timer_outlined, '95%', 'Response Rate'),
          _buildStatItem(Icons.camera_alt_outlined, '342', 'Projects'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Container(
      width: 75.w,
      height: 85.h,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15).r,
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18.sp, color: Colors.black54),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppTypography.bodyLarge,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp.clamp(10, 11),
              color: Colors.grey,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 38.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(30).r,
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {});
        },
        indicator: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(30).r,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: TextStyle(
          fontSize: 13.sp.clamp(12, 14),
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 13.sp.clamp(12, 14),
          fontWeight: FontWeight.normal,
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
              imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=500',
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
              'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=500',
              'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=500',
              'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=500',
              'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=500',
              'https://images.unsplash.com/photo-1520854221256-17d51cc3c663?q=80&w=500',
              'https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?q=80&w=500',
              'https://images.unsplash.com/photo-1510076857177-7470076d4098?q=80&w=500',
              'https://images.unsplash.com/photo-1523438885200-e635ba2c371e?q=80&w=500',
            ];
            return ClipRRect(
              borderRadius: BorderRadius.circular(12).r,
              child: Image.network(
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
                    backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200'),
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
                  _buildReviewImage('https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=200'),
                  SizedBox(width: 10.w),
                  _buildReviewImage('https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=200'),
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
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
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
