import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/client/widgets/service_card.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/review_controller.dart';
import 'package:photopia/controller/client/service_list_controller.dart';
import 'package:photopia/controller/client/provider_details_controller.dart';
import 'package:photopia/core/widgets/custom_network_image.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/utils/guest_dialog_helper.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Robust ID extraction
      dynamic rawId = widget.provider['_id'] ?? widget.provider['id'];
      
      if (rawId is Map) {
        rawId = rawId['_id'] ?? rawId['id'];
      }
      
      // If still null, check if there's a nested providerId object
      if (rawId == null && widget.provider['providerId'] != null) {
        final pId = widget.provider['providerId'];
        if (pId is Map) {
          rawId = pId['_id'] ?? pId['id'];
        } else {
          rawId = pId;
        }
      }
      
      final String? providerId = rawId?.toString();
      debugPrint("🚀 [ProviderProfileScreen] Initializing with ID: $providerId");
      
      if (providerId != null && providerId.isNotEmpty) {
        context.read<ServiceListController>().getProviderServices(providerId);
        context.read<ProviderDetailsController>().getProviderDetails(
          providerId,
        );
        context.read<ReviewController>().getProviderReviews(providerId);
      } else {
        debugPrint("⚠️ [ProviderProfileScreen] No valid provider ID found in widget.provider: ${widget.provider}");
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
                      'location': 'Barcelona, Spain',
                    },
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.outlined_flag, color: Colors.blueGrey, size: 24.sp),
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
            SizedBox(height: 100.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
    final avatar = providerDetails?.profile ?? widget.provider['avatar']?.toString();
    final name = providerDetails?.fullName ?? widget.provider['name']?.toString() ?? 'Provider Name';
    String categoryDisplay = 'Wedding & Event Photography';
    final prof = controller.profProfileDetails;
    
    // Use Bio if available, else use Specialty, else static fallback
    if (prof?.bio != null && prof!.bio!.isNotEmpty) {
      categoryDisplay = prof.bio!;
    } else if (prof?.specialty != null && prof!.specialty!.isNotEmpty) {
      categoryDisplay = prof.specialty!;
    } else if (providerDetails?.specialty != null && providerDetails!.specialty!.isNotEmpty) {
      categoryDisplay = providerDetails.specialty!;
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
                          ? CustomNetworkImage(imageUrl: avatar, fit: BoxFit.cover)
                          : Image.asset('assets/images/img6.png', fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        if (isLoading)
                          SizedBox(height: 14.h, width: 100.w, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))
                        else
                          Text(categoryDisplay, style: TextStyle(fontSize: 13.sp, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w400)),
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30).r),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stars, color: Colors.white, size: 12.sp),
                              SizedBox(width: 6.w),
                              Text('Premium', style: TextStyle(color: Colors.white, fontSize: 10.5.sp, fontWeight: FontWeight.bold)),
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
      return SizedBox(height: 90.h, child: const Center(child: CircularProgressIndicator(color: Colors.black54)));
    }
    
    // Pull data from professional profile first, then fallback to user details or widget map
    final prof = controller.profProfileDetails;
    final user = controller.providerDetails;

    final rating = prof?.rating?.toString() ?? '0.0';
    final reviews = prof?.reviewCount?.toString() ?? '0';
    final responseRate = prof?.responseRate != null ? '${prof!.responseRate}%' : '0%';
    final projectsCount = prof?.projects?.toString() ?? (user?.id != null ? '0' : '0');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(Icons.star_border, rating, 'Rating'),
        _buildStatItem(Icons.verified_outlined, reviews, 'Reviews'),
        _buildStatItem(Icons.military_tech_outlined, responseRate, 'Response Rate'),
        _buildStatItem(Icons.camera_alt_outlined, projectsCount, 'Projects'),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Container(
      width: 78.w,
      height: 90.h,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10).r, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(icon, size: 22.sp, color: Colors.black87),
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black))),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600], height: 1, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 35.h,
      decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(30).r),
      child: TabBar(
        controller: _tabController,
        padding: EdgeInsets.all(4.w),
        indicator: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(30).r),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF455A64),
        labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text('Portfolio'))),
          Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Consumer<ReviewController>(builder: (context, controller, child) => Text('Reviews (${controller.reviews.length})')))),
          Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text('About'))),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return [
      _buildPortfolioContent(),
      _buildReviewsContent(),
      _buildAboutContent(),
    ][_tabController.index];
  }

  Widget _buildPortfolioContent() {
    return Consumer2<ServiceListController, ProviderDetailsController>(
      builder: (context, serviceController, detailsController, child) {
        final isLoading = serviceController.isLoading;
        final services = serviceController.services;

        // Get portfolio images from professional profile
        final portfolioImages = detailsController.profProfileDetails?.portfolio
            ?.map((e) => e.toString())
            .where((url) => url.isNotEmpty)
            .toList() ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Services Offered', style: TextStyle(fontSize: AppTypography.h2, fontWeight: FontWeight.bold)),
            SizedBox(height: 15.h),
            if (isLoading)
              GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 0.55), itemCount: 2, itemBuilder: (context, index) => const ServiceCardSkeleton())
            else if (services.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('No services found.')))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, childAspectRatio: 0.55),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return ServiceCard(
                    id: service.sId ?? '',
                    title: service.title ?? 'Service',
                    subtitle: widget.provider['name'] ?? 'Provider',
                    imageUrl: service.coverMedia ?? '',
                    rating: service.rating ?? 0.0,
                    reviews: service.reviews ?? 0,
                    priceRange: '€${service.price ?? 0}',
                    tags: const [],
                    isPremium: false,
                    providerId: widget.provider['_id'] ?? widget.provider['id'],
                  );
                },
              ),

            // Portfolio images from professional profile
            if (portfolioImages.isNotEmpty) ...[
              SizedBox(height: 30.h),
              Text('Portfolio', style: TextStyle(fontSize: AppTypography.h2, fontWeight: FontWeight.bold)),
              SizedBox(height: 15.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1,
                ),
                itemCount: portfolioImages.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12).r,
                    child: CustomNetworkImage(
                      imageUrl: portfolioImages[index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildReviewsContent() {
    return Consumer<ReviewController>(
      builder: (context, controller, child) {
        if (controller.isLoading) return const Center(child: CircularProgressIndicator());
        final reviews = controller.reviews;
        if (reviews.isEmpty) return const Center(child: Text('No reviews yet'));
        return Column(
          children: reviews.map((review) => Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 20.r, backgroundImage: const AssetImage('assets/images/img7.jpg')),
                    SizedBox(width: 12.w),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(review.user?.name ?? 'Anonymous', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      Row(children: List.generate(5, (i) => Icon(Icons.star, color: i < (review.rating ?? 0) ? Colors.orange : Colors.grey[300], size: 14.sp))),
                    ]),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(review.comment ?? '', style: TextStyle(fontSize: 13.sp, color: Colors.black87)),
              ],
            ),
          )).toList(),
        );
      },
    );
  }

  Widget _buildAboutContent() {
    return Consumer<ProviderDetailsController>(
      builder: (context, controller, child) {
        // Data sources
        final userProfile = controller.providerDetails;
        final profProfile = controller.profProfileDetails;

        // Description priority
        final description = 
            profProfile?.user?.description ??
            userProfile?.description ?? 
            widget.provider['description']?.toString() ??
            "";
        
        // Member since from createdAt
        String memberSince = "";
        if (userProfile?.createdAt != null) {
          try {
            final date = DateTime.parse(userProfile!.createdAt!);
            memberSince = "Member since ${date.year}";
          } catch (_) {}
        }

        // Combine languages and specializations from both models
        final List<String> languages = [
          ...?(userProfile?.languages),
          ...?(profProfile?.language?.map((e) => e.toString())),
        ].toSet().where((e) => e.isNotEmpty).toList();

        final List<String> specializations = [
          if (userProfile?.specialty != null && userProfile!.specialty!.isNotEmpty) userProfile.specialty!,
          ...?(profProfile?.specialties?.map((e) => e.toString())),
        ].toSet().where((e) => e.isNotEmpty).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Me',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              description.isEmpty ? "No description available." : description,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF455A64),
                height: 1.6,
              ),
            ),
            if (memberSince.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Text(
                memberSince,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF90A4AE),
                ),
              ),
            ],
            
            if (languages.isNotEmpty) ...[
              SizedBox(height: 25.h),
              Text(
                'Languages',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: languages.map((item) => _buildReadOnlyChip(item)).toList(),
              ),
            ],

            if (specializations.isNotEmpty) ...[
              SizedBox(height: 25.h),
              Text(
                'Specializations',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: specializations.map((item) => _buildReadOnlyChip(item)).toList(),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildReadOnlyChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F9),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFECEFF1)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp, 
          color: const Color(0xFF455A64),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
