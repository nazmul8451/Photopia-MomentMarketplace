import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/controller/client/service_list_controller.dart';
import 'package:photopia/controller/client/notification_controller.dart';
import 'package:photopia/controller/location_controller.dart';
import 'package:photopia/controller/client/home_controller.dart';
import 'package:photopia/data/models/service_list_model.dart';
import 'package:photopia/data/models/home_data_model.dart';
import 'package:photopia/features/client/widgets/home_header.dart';
import 'package:photopia/features/client/widgets/category_bar.dart';
import 'package:photopia/features/client/widgets/section_header.dart';
import 'package:photopia/features/client/widgets/horizontal_project_card.dart';
import 'package:photopia/features/client/category_details_screen.dart';
import 'package:photopia/features/client/service_details_screen.dart';
import 'package:photopia/features/client/search_result_screen.dart';
import 'package:flutter/services.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:photopia/controller/category_controller.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  static const String name = "/home-page";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeController = context.read<HomeController>();
      if (homeController.homeData == null) {
        homeController.fetchHomeData();
      }
      context.read<CategoryController>().getAllCategories();
      context.read<LocationController>().determinePosition();
      context.read<NotificationController>().fetchNotificationStats();

      // Also fetch ServiceList in background to allow standard list tabs if needed
      context.read<ServiceListController>().getAllServices(refresh: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToCategoryDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CategoryDetailsScreen()),
    );
  }

  void _navigateToServiceDetails(BuildContext context, ServiceItem service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceDetailsScreen(service: service.toJson()),
      ),
    );
  }

  Widget _buildHorizontalServiceSection({
    required String title,
    required List<ServiceItem> items,
    bool showAvailability = false,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, onSeeAllTap: () {}),
        SizedBox(
          height: 280.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return HorizontalProjectCard(
                id: item.sId,
                providerId: item.providerId?.sId,
                imageUrl: item.coverMedia ?? '',
                title: item.title ?? 'No Title',
                providerName: item.providerId?.name ?? 'Unknown Provider',
                rating: item.rating,
                price: item.price,
                tags: item.tags,
                isAvailable: showAvailability && (item.isActive ?? false),
                onTap: () => _navigateToServiceDetails(context, item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyViewed(List<RecentlyViewedItem>? items) {
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    // Extract services
    final validServices = items
        .where((i) => i.serviceId != null)
        .map((i) => i.serviceId!)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Recently Viewed', onSeeAllTap: () {}),
        SizedBox(
          height: 280.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: validServices.length,
            itemBuilder: (context, index) {
              final item = validServices[index];
              return HorizontalProjectCard(
                id: item.sId,
                providerId: item.providerId?.sId,
                imageUrl: item.coverMedia ?? '',
                title: item.title ?? 'No Title',
                providerName: item.providerId?.name ?? 'Provider',
                rating: item.rating,
                price: item.price,
                tags: item.tags,
                isAvailable: false,
                onTap: () => _navigateToServiceDetails(context, item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInspirations(List<Inspiration>? items) {
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Get Inspired', onSeeAllTap: () {}),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 200.w,
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.black54],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.icon ?? '💡', style: TextStyle(fontSize: 24.sp)),
                    SizedBox(height: 8.h),
                    Text(
                      item.title ?? 'Idea',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.description ?? '',
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuperPros(List<SuperPro>? items) {
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Super Pros', onSeeAllTap: () {}),
        SizedBox(
          height: 140.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final pro = items[index];
              return Container(
                width: 110.w,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(12.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 30.r,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: pro.user?.profile != null
                              ? CachedNetworkImageProvider(pro.user!.profile!)
                              : null,
                          child: pro.user?.profile == null
                              ? Icon(Icons.person, color: Colors.grey)
                              : null,
                        ),
                        if (pro.isSuperPro == true)
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 10.sp,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      pro.user?.name ?? 'Pro',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.orange,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          pro.rating?.toStringAsFixed(1) ?? '5.0',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget _buildStylesTags(BuildContext context, List<String>? styles) {
  //   if (styles == null || styles.isEmpty) return const SizedBox.shrink();

  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Explore Styles',
  //           style: TextStyle(
  //             fontSize: 16.sp,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         SizedBox(height: 10.h),
  //         Wrap(
  //           spacing: 8.w,
  //           runSpacing: 8.h,
  //           children: styles.map((style) {
  //             return Material(
  //               color: Colors.transparent,
  //               child: InkWell(
  //                 borderRadius: BorderRadius.circular(20.r),
  //                 onTap: () {
  //                   Navigator.of(context).push(
  //                     MaterialPageRoute(
  //                       builder: (context) => SearchResultScreen(
  //                         filters: {'theme': style},
  //                       ),
  //                     ),
  //                   );
  //                 },
  //                 child: Container(
  //                   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey.shade100,
  //                     borderRadius: BorderRadius.circular(20.r),
  //                     border: Border.all(color: Colors.grey.shade300),
  //                   ),
  //                   child: Text(
  //                     style,
  //                     style: TextStyle(
  //                       fontSize: 13.sp,
  //                       color: Colors.black87,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             );
  //           }).toList(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildPopularLocations(BuildContext context, List<PopularLocation>? locs) {
  //   if (locs == null || locs.isEmpty) return const SizedBox.shrink();

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       SectionHeader(title: 'Top Cities', onSeeAllTap: (){}),
  //       SizedBox(
  //         height: 140.h,
  //         child: ListView.builder(
  //           padding: EdgeInsets.symmetric(horizontal: 16.w),
  //           scrollDirection: Axis.horizontal,
  //           physics: const BouncingScrollPhysics(),
  //           itemCount: locs.length,
  //           itemBuilder: (context, index) {
  //             final loc = locs[index];
  //             return GestureDetector(
  //               onTap: () {
  //                 Navigator.of(context).push(
  //                   MaterialPageRoute(
  //                     builder: (context) => SearchResultScreen(
  //                       // Backend usually filters exact city matches via 'city'
  //                       filters: {'city': loc.id},
  //                     ),
  //                   ),
  //                 );
  //               },
  //               child: Container(
  //                 width: 140.w,
  //                 margin: EdgeInsets.only(right: 12.w),
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(16.r),
  //                   color: Colors.grey.shade200,
  //                   image: loc.image != null ? DecorationImage(
  //                     image: CachedNetworkImageProvider(loc.image!),
  //                     fit: BoxFit.cover,
  //                   ) : null,
  //                 ),
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(16.r),
  //                     gradient: LinearGradient(
  //                       begin: Alignment.topCenter,
  //                       end: Alignment.bottomCenter,
  //                       colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
  //                     ),
  //                   ),
  //                   padding: EdgeInsets.all(12.w),
  //                   alignment: Alignment.bottomLeft,
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         loc.id ?? 'City',
  //                         style: TextStyle(
  //                           color: Colors.white,
  //                           fontSize: 14.sp,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                         maxLines: 1,
  //                       ),
  //                       Text(
  //                         '${loc.count ?? 0} Pros',
  //                         style: TextStyle(
  //                           color: Colors.white70,
  //                           fontSize: 11.sp,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Sticky Header Section with Shadow and Top Padding for Status Bar
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(15.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Consumer<ServiceListController>(
                builder: (context, serviceListController, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const HomeHeader(),
                      // Category Bar relies on ServiceListController for filtering
                      CategoryBar(
                        isLoading: serviceListController.isLoading,
                        selectedCategoryId: context
                            .watch<CategoryController>()
                            .selectedCategoryId,
                        onCategorySelected: (categoryId) {
                          context.read<CategoryController>().selectCategory(
                            categoryId,
                          );
                          serviceListController.getAllServices(
                            filters: {'category': categoryId},
                          );
                        },
                      ),
                      SizedBox(height: 15.h),
                    ],
                  );
                },
              ),
            ),
            // Scrollable Dynamic Home Content
            Expanded(
              child: Consumer<HomeController>(
                builder: (context, homeController, child) {
                  if (homeController.isLoading &&
                      homeController.homeData == null) {
                    return const HomeShimmer();
                  }

                  if (homeController.errorMessage != null &&
                      homeController.homeData == null) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              size: 60.sp,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Unable to load home',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            ElevatedButton(
                              onPressed: () => homeController.fetchHomeData(),
                              child: Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final data = homeController.homeData;
                  if (data == null) {
                    return const Center(child: Text('No Data'));
                  }

                  return RefreshIndicator(
                    color: Colors.black,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      await homeController.fetchHomeData();
                      context.read<CategoryController>().getAllCategories();
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.h),

                          // Inspirations
                          if (data.inspirations != null &&
                              data.inspirations!.isNotEmpty)
                            Column(
                              children: [
                                _buildInspirations(data.inspirations),
                                SizedBox(height: 20.h),
                              ],
                            ),

                          // Original Projects
                          if (data.originalProjects != null)
                            _buildHorizontalServiceSection(
                              title: 'Original Projects',
                              items: data.originalProjects!,
                            ),

                          SizedBox(height: 10.h),

                          // Recently Viewed
                          if (data.recentlyViewed != null &&
                              data.recentlyViewed!.isNotEmpty)
                            Column(
                              children: [
                                _buildRecentlyViewed(data.recentlyViewed),
                                SizedBox(height: 10.h),
                              ],
                            ),

                          // Available Right Now
                          if (data.availableNow != null)
                            _buildHorizontalServiceSection(
                              title: 'Available Right Now',
                              items: data.availableNow!,
                              showAvailability: true,
                            ),

                          SizedBox(height: 10.h),

                          // Super Pros
                          if (data.superPros != null &&
                              data.superPros!.isNotEmpty)
                            Column(
                              children: [
                                _buildSuperPros(data.superPros),
                                SizedBox(height: 10.h),
                              ],
                            ),

                          // Trending Projects / Subcategories
                          // Assuming we map subcategories textually or map them to visual blocks
                          // Or we fallback to styles
                          // _buildStylesTags(context, data.styles),
                          SizedBox(height: 10.h),

                          // Popular Locations
                          if (data.popularLocations != null &&
                              data.popularLocations!.isNotEmpty)
                            Column(
                              children: [
                                //  _buildPopularLocations(context, data.popularLocations),
                                SizedBox(height: 10.h),
                              ],
                            ),

                          SizedBox(
                            height: 100.h,
                          ), // Bottom padding for navigation bar
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
