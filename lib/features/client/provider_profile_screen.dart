import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'package:photopia/core/widgets/subscription_badge.dart';
import 'package:photopia/core/widgets/full_screen_image_viewer.dart';
import 'package:photopia/features/client/widgets/auth_profile_image.dart';

class ProviderProfileScreen extends StatefulWidget {
  final Map<String, dynamic> provider;

  const ProviderProfileScreen({super.key, required this.provider});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _providerId;

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

      // If still null, check if there's a nested providerId/user object
      if (rawId == null) {
        if (widget.provider['providerId'] != null) {
          rawId = widget.provider['providerId'] is Map
              ? widget.provider['providerId']['_id']
              : widget.provider['providerId'];
        } else if (widget.provider['user'] != null) {
          rawId = widget.provider['user'] is Map
              ? widget.provider['user']['_id']
              : widget.provider['user'];
        }
      }

      _providerId = rawId?.toString();
      debugPrint("🚀 [SCREEN] Navigated to Provider: $_providerId");

      if (_providerId != null && _providerId!.isNotEmpty) {
        // Clear old state before fetching new data to avoid UI flickers or double calls
        context.read<ServiceListController>().getProviderServices(_providerId!);
        context.read<ProviderDetailsController>().getProviderDetails(
          _providerId!,
        );
        context.read<ReviewController>().getProviderReviews(_providerId!);
        setState(() {});
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
                    optimisticData: {...widget.provider},
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.outlined_flag,
              color: Colors.blueGrey,
              size: 24.sp,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 10.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Consumer<ProviderDetailsController>(
                  builder: (context, controller, child) {
                    final String? cover =
                        controller.profProfileDetails?.coverPhoto;
                    return CustomNetworkImage(
                      imageUrl: (cover != null && cover.isNotEmpty)
                          ? cover
                          : 'assets/images/img5.png',
                      height: 220.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
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
                Positioned(
                  bottom: -5.h,
                  left: 6.w,
                  right: 6.w,
                  child: Consumer<ProviderDetailsController>(
                    builder: (context, controller, child) =>
                        _buildProfileInfo(controller),
                  ),
                ),
                Positioned(
                  bottom: -80.h,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Consumer<ProviderDetailsController>(
                      builder: (context, controller, child) =>
                          _buildStatsRow(controller),
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
    final avatar =
        providerDetails?.profile ??
        widget.provider['avatar'] ??
        widget.provider['profile'] ??
        '';
    final name =
        providerDetails?.fullName ??
        widget.provider['name']?.toString() ??
        'Provider Name';

    final prof = controller.profProfileDetails;
    // For the tagline under the name, prefer Bio (short)
    String tagline = 'Professional Photographer';
    if (prof?.bio != null && prof!.bio!.isNotEmpty) {
      tagline = prof.bio!;
    } else if (providerDetails?.specialty != null &&
        providerDetails!.specialty!.isNotEmpty) {
      tagline = providerDetails.specialty!;
    } else if (widget.provider['description'] != null &&
        widget.provider['description'].toString().isNotEmpty) {
      tagline = widget.provider['description'].toString();
    }

    if (tagline.length > 80) tagline = "${tagline.substring(0, 77)}...";

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
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (avatar.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImageViewer(
                              imageUrl: avatar,
                              tag: 'header_avatar',
                            ),
                          ),
                        );
                      }
                    },
                    child: Hero(
                      tag: 'header_avatar',
                      child: AuthProfileImage(imageUrl: avatar, size: 75.r),
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
                        Text(
                          tagline,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        SubscriptionBadge(
                          isSubscribed: prof?.isSubscribed ?? false,
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

  Widget _buildStatsRow(ProviderDetailsController controller) {
    if (controller.isLoading) return const StatsRowSkeleton();
    final prof = controller.profProfileDetails;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          Icons.star_border,
          prof?.rating?.toString() ?? '0.0',
          'Rating',
        ),
        _buildStatItem(
          Icons.verified_outlined,
          prof?.reviewCount?.toString() ?? '0',
          'Reviews',
        ),
        _buildStatItem(
          Icons.military_tech_outlined,
          '${prof?.responseRate ?? 0}%',
          'Response',
        ),
        _buildStatItem(
          Icons.camera_alt_outlined,
          prof?.projects?.toString() ?? '0',
          'Projects',
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Container(
      width: 78.w,
      height: 90.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10).r,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22.sp),
          Text(
            value,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey),
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
        indicator: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(30).r,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF455A64),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: [
          const Tab(text: 'Portfolio'),
          Tab(
            child: Consumer<ReviewController>(
              builder: (context, c, _) => Text('Reviews (${c.reviews.length})'),
            ),
          ),
          const Tab(text: 'About'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: [
        SingleChildScrollView(
          key: const ValueKey('portfolio_scroll'),
          physics: const NeverScrollableScrollPhysics(),
          child: _buildPortfolioContent(key: const ValueKey('portfolio')),
        ),
        SingleChildScrollView(
          key: const ValueKey('reviews_scroll'),
          physics: const NeverScrollableScrollPhysics(),
          child: _buildReviewsContent(key: const ValueKey('reviews')),
        ),
        SingleChildScrollView(
          key: const ValueKey('about_scroll'),
          physics: const NeverScrollableScrollPhysics(),
          child: _buildAboutContent(key: const ValueKey('about')),
        ),
      ][_tabController.index],
    );
  }

  Widget _buildPortfolioContent({Key? key}) {
    return Consumer2<ServiceListController, ProviderDetailsController>(
      key: key,
      builder: (context, serviceController, detailsController, child) {
        final isLoading = serviceController.isLoading;
        final services = serviceController.services;
        final prof = detailsController.profProfileDetails;
        final providerDetails = detailsController.providerDetails;
        final name =
            providerDetails?.fullName ??
            widget.provider['name']?.toString() ??
            'Provider Name';

        final portfolioImages =
            prof?.portfolio
                ?.map((e) => e.toString())
                .where((s) => s.isNotEmpty)
                .toList() ??
            [];
        final documents =
            prof?.documents
                ?.map((e) => e.toString())
                .where((s) => s.isNotEmpty)
                .toList() ??
            [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (services.isNotEmpty) ...[
              Text(
                'Services Offered',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 0.55,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final s = services[index];
                  return ServiceCard(
                    id: s.sId ?? '',
                    title: s.title ?? 'Service',
                    subtitle:
                        name, // Use the name calculated at the top of the widget
                    imageUrl: s.coverMedia ?? '',
                    rating: s.rating ?? 0.0,
                    reviews: s.reviews ?? 0,
                    price: s.price,
                    currency: s.currency,
                    tags: const [],
                    isPremium: prof?.isSubscribed ?? false,
                    providerId: _providerId,
                  );
                },
              ),
              SizedBox(height: 24.h),
            ],

            if (portfolioImages.isNotEmpty) ...[
              Text(
                'Portfolio Images',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: portfolioImages.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageViewer(
                        imageUrl: portfolioImages[index],
                        tag: 'portfolio_$index',
                      ),
                    ),
                  ),
                  child: Hero(
                    tag: 'portfolio_$index',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CustomNetworkImage(
                        imageUrl: portfolioImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],

            if (documents.isNotEmpty) ...[
              Text(
                'Documents',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              ...documents.map((docUrl) {
                final fileName = docUrl.split('/').last;
                return Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.description, color: Colors.blue),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.remove_red_eye_outlined,
                          color: Colors.blue,
                        ),
                        onPressed: () async {
                          final uri = Uri.parse(docUrl);
                          if (await canLaunchUrl(uri))
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],

            if (!isLoading &&
                services.isEmpty &&
                portfolioImages.isEmpty &&
                documents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No content available'),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildReviewsContent({Key? key}) {
    return Consumer<ReviewController>(
      key: key,
      builder: (context, controller, child) {
        if (controller.isLoading) return const ReviewListSkeleton();
        if (controller.reviews.isEmpty)
          return const Center(child: Text('No reviews yet'));
        return Column(
          children: controller.reviews
              .map(
                (r) => Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20.r,
                            backgroundImage: r.user?.profile != null
                                ? NetworkImage(r.user!.profile!)
                                : const AssetImage('assets/images/img7.jpg'),
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.user?.name ?? 'User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    Icons.star,
                                    color: i < (r.rating ?? 0)
                                        ? Colors.orange
                                        : Colors.grey[300],
                                    size: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        r.comment ?? '',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildAboutContent({Key? key}) {
    return Consumer<ProviderDetailsController>(
      key: key,
      builder: (context, controller, child) {
        final prof = controller.profProfileDetails;
        final user = controller.providerDetails;

        // Use full description from user profile first, then bio
        String description = 'No description available.';
        if (user?.description != null && user!.description!.isNotEmpty) {
          description = user.description!;
        } else if (prof?.user?.description != null &&
            prof!.user!.description!.isNotEmpty) {
          description = prof.user!.description!;
        } else if (prof?.bio != null && prof!.bio!.isNotEmpty) {
          description = prof.bio!;
        } else if (widget.provider['description'] != null &&
            widget.provider['description'].toString().isNotEmpty) {
          description = widget.provider['description'].toString();
        }

        final List<String> languages =
            (prof?.language?.map((e) => e.toString()).toList() ?? []) +
            (user?.languages ?? []);
        final List<String> specializations =
            (prof?.specialties?.map((e) => e.toString()).toList() ?? []) +
            (prof?.specialty != null && prof!.specialty!.isNotEmpty
                ? [prof.specialty!]
                : []) +
            (user?.specialty != null && user!.specialty!.isNotEmpty
                ? [user.specialty!]
                : []);

        final location =
            user?.location ?? widget.provider['location']?.toString() ?? 'N/A';
        final email =
            user?.email ?? widget.provider['email']?.toString() ?? 'N/A';
        final phone =
            user?.phone ?? widget.provider['phone']?.toString() ?? 'N/A';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Me',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.5,
              ),
            ),

            SizedBox(height: 25.h),
            _buildAboutDetailItem(
              Icons.location_on_outlined,
              'Location',
              location,
            ),
            _buildAboutDetailItem(Icons.email_outlined, 'Email', email),
            _buildAboutDetailItem(Icons.phone_outlined, 'Phone', phone),

            if (languages.isNotEmpty) ...[
              SizedBox(height: 25.h),
              Text(
                'Languages',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: languages
                    .toSet()
                    .where((l) => l.isNotEmpty)
                    .map((l) => _buildChip(l))
                    .toList(),
              ),
            ],
            if (specializations.isNotEmpty) ...[
              SizedBox(height: 25.h),
              Text(
                'Specializations',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: specializations
                    .toSet()
                    .where((s) => s.isNotEmpty)
                    .map((s) => _buildChip(s))
                    .toList(),
              ),
            ],
            SizedBox(height: 20.h),
          ],
        );
      },
    );
  }

  Widget _buildAboutDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.sp, color: Colors.black54),
          ),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 12.sp)),
      backgroundColor: Colors.grey[100],
      side: BorderSide.none,
    );
  }
}
