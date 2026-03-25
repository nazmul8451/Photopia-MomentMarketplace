import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/client/widgets/service_card.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/service_list_controller.dart';
import 'package:photopia/controller/client/provider_details_controller.dart';
import 'package:photopia/core/widgets/custom_network_image.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/utils/guest_dialog_helper.dart';
import 'package:photopia/controller/client/favorites_controller.dart';
import 'package:photopia/data/models/service_list_model.dart';

class ProviderProfileScreen extends StatefulWidget {
  final Map<String, dynamic> provider;

  const ProviderProfileScreen({super.key, required this.provider});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      dynamic rawId = widget.provider['_id'] ?? widget.provider['id'];
      
      // If rawId is itself a Map (due to incorrect passing), extract the ID from it
      if (rawId is Map) {
        rawId = rawId['_id'] ?? rawId['id'];
      }
      
      final String? providerId = rawId?.toString();
      
      if (providerId != null && providerId.isNotEmpty) {
        context.read<ServiceListController>().getProviderServices(providerId);
        context.read<ProviderDetailsController>().getProviderDetails(
          providerId,
        );
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
              bool isFavorite = controller.isProviderFavorite(
                widget.provider['_id'] ?? widget.provider['id'],
              );
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.black,
                  size: 24.sp,
                ),
                onPressed: () {
                  if (!AuthController.isLoggedIn) {
                    GuestDialogHelper.showGuestDialog(context);
                    return;
                  }
                  controller.toggleFavorite(
                    providerId: widget.provider['_id'] ?? widget.provider['id'],
                    optimisticData: {
                      ...widget.provider,
                      'isPremium': true,
                      'category': 'Wedding & Event Photography',
                      'location':
                          'Barcelona, Spain', // Matching ProviderCard default for now
                    },
                  );
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
                  height: 220.h,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/img5.png'),
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
                  child: Consumer<ProviderDetailsController>(
                    builder: (context, controller, child) {
                      return _buildProfileInfo(controller);
                    },
                  ),
                ),

                // Overlapping Stats Row
                Positioned(
                  bottom: -80.h,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Consumer<ProviderDetailsController>(
                      builder: (context, controller, child) {
                        return _buildStatsRow(controller);
                      },
                    ),
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

  Widget _buildProfileInfo(ProviderDetailsController controller) {
    final providerDetails = controller.providerDetails;
    final isLoading = controller.isLoading;

    // Fallback to widget.provider if API data is loading or missing
    final avatar = providerDetails?.profile ?? widget.provider['avatar']?.toString();
    final name =
        providerDetails?.fullName ?? widget.provider['name']?.toString() ?? 'Provider Name';

    // Handle category name extraction
    String categoryDisplay = 'Wedding & Event Photography';
    if (providerDetails?.specialty != null &&
        providerDetails!.specialty!.isNotEmpty) {
      categoryDisplay = providerDetails.specialty!;
    } else if (widget.provider['category'] != null &&
        widget.provider['category'].toString().isNotEmpty) {
      categoryDisplay = widget.provider['category'].toString();
    }

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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5.w),
                    ),
                    child: ClipOval(
                      child: avatar != null && avatar.toString().isNotEmpty
                          ? CustomNetworkImage(
                              imageUrl: avatar,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/img6.png',
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
                          name,
                          style: TextStyle(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        if (isLoading)
                          SizedBox(
                            height: 14.h,
                            width: 100.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white54,
                            ),
                          )
                        else
                          Text(
                            categoryDisplay,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

  Widget _buildStatsRow(ProviderDetailsController controller) {
    if (controller.isLoading) {
      return SizedBox(
        height: 90.h,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.black54),
        ),
      );
    }

    // Always display the cards, fallback to defaults or placeholders if data is missing.
    final dynamic providerData =
        controller.providerDetails?.toJson() ?? widget.provider;

    final rating = providerData['rating']?.toString() ?? '4.9';
    final reviews = providerData['reviews']?.toString() ?? '127';
    final responseRate = providerData['responseRate']?.toString() ?? '95%';
    final projectsCount =
        providerData['projectsCount']?.toString() ??
        providerData['projects']?.toString() ??
        '342';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(Icons.star_border, rating, 'Rating'),
        _buildStatItem(Icons.verified_outlined, reviews, 'Reviews'),
        _buildStatItem(
          Icons.military_tech_outlined,
          responseRate,
          'Response Rate',
        ),
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
            child: FittedBox(fit: BoxFit.scaleDown, child: Text('Portfolio')),
          ),
          Consumer<ProviderDetailsController>(
            builder: (context, controller, child) {
              final dynamic providerData =
                  controller.providerDetails?.toJson() ?? widget.provider;
              final reviews = providerData['reviews']?.toString() ?? '127';
              return Tab(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Reviews ($reviews)'),
                ),
              );
            },
          ),
          Tab(
            child: FittedBox(fit: BoxFit.scaleDown, child: Text('About')),
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
    return Consumer<ServiceListController>(
      builder: (context, controller, child) {
        final isLoading = controller.isLoading;
        final services = controller.services;

        // Extract all gallery items from all services for the Recent Work section
        final List<String> allGalleryImages = [];
        for (var service in services) {
          if (service.gallery != null) {
            for (var img in service.gallery!) {
              if (img != null && img.toString().isNotEmpty) {
                allGalleryImages.add(img.toString());
              }
            }
          }
        }

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
            if (isLoading)
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
                itemCount: 2,
                itemBuilder: (context, index) => const ServiceCardSkeleton(),
              )
            else if (services.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Text(
                    'No services found.',
                    style: TextStyle(
                      fontSize: AppTypography.bodyLarge,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
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
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final dynamic service = services[index];
                  return ServiceCard(
                    id: (service is ServiceItem) ? service.sId : service['_id']?.toString(),
                    title: (service is ServiceItem) ? (service.title ?? 'Service') : (service['title']?.toString() ?? 'Service'),
                    subtitle: (service is ServiceItem) 
                        ? (service.providerId?.name ?? widget.provider['name'] ?? 'Provider')
                        : (service['providerId']?['name'] ?? widget.provider['name'] ?? 'Provider'),
                    imageUrl: (service is ServiceItem) ? (service.coverMedia ?? '') : (service['coverMedia']?.toString() ?? ''),
                    rating: (service is ServiceItem) ? (service.rating ?? 0.0) : (double.tryParse(service['rating']?.toString() ?? '0.0') ?? 0.0),
                    reviews: (service is ServiceItem) ? (service.reviews ?? 0) : (int.tryParse(service['reviews']?.toString() ?? '0') ?? 0),
                    priceRange: (service is ServiceItem) 
                        ? '€${service.price ?? 0}'
                        : '€${service['price'] ?? 0}',
                    tags: const [],
                    isPremium: false,
                    providerId: (service is ServiceItem) 
                        ? (service.providerId?.sId ?? widget.provider['_id'] ?? widget.provider['id'])
                        : (service['providerId']?['_id'] ?? widget.provider['_id'] ?? widget.provider['id']),
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
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (allGalleryImages.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Text(
                    'No recent work available.',
                    style: TextStyle(
                      fontSize: AppTypography.bodyLarge,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
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
                itemCount: allGalleryImages.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12).r,
                    child: CustomNetworkImage(
                      imageUrl: allGalleryImages[index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
          ],
        );
      },
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
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 14.sp,
                                ),
                              ),
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
    return Consumer<ProviderDetailsController>(
      builder: (context, controller, child) {
        final description =
            controller.providerDetails?.description ??
            widget.provider['description'] ??
            "Professional wedding and event photographer with over 8 years of experience capturing life's most precious moments. I specialize in candid, emotional photography that tells your unique story. My approach combines artistic vision with journalistic documentation to create timeless images you'll treasure forever.";

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
              description.toString().isNotEmpty
                  ? description
                  : "No description available.",
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
      },
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
