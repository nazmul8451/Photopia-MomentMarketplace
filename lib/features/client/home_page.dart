import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/controller/client/service_list_controller.dart';
import 'package:photopia/controller/location_controller.dart';
import 'package:photopia/data/models/service_list_model.dart';
import 'package:photopia/features/client/widgets/home_header.dart';
import 'package:photopia/features/client/widgets/category_bar.dart';
import 'package:photopia/features/client/widgets/section_header.dart';
import 'package:photopia/features/client/widgets/horizontal_project_card.dart';
import 'package:photopia/features/client/category_details_screen.dart';
import 'package:photopia/features/client/service_details_screen.dart';
import 'package:flutter/services.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  static const String name = "/home-page";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedCategoryIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load services from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ServiceListController>();
      if (controller.services.isEmpty) {
        controller.getAllServices();
      }
      context.read<LocationController>().determinePosition();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more content here
    }
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

  Widget _buildHorizontalSection({
    required String title,
    required List<ServiceItem> items,
    bool showAvailability = false,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onSeeAllTap: () => _navigateToCategoryDetails(context),
        ),
        SizedBox(
          height: 230.h,
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
                isAvailable: showAvailability && (item.isActive ?? false),
                onTap: () => _navigateToServiceDetails(context, item),
              );
            },
          ),
        ),
      ],
    );
  }

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
                      CategoryBar(
                        isLoading: serviceListController.isLoading,
                        selectedIndex: _selectedCategoryIndex,
                        onCategorySelected: (index) {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                      ),
                      SizedBox(height: 15.h),
                    ],
                  );
                },
              ),
            ),
            // Scrollable Content with Horizontal Sections
            Expanded(
              child: Consumer<ServiceListController>(
                builder: (context, serviceListController, child) {
                  if (serviceListController.isLoading &&
                      serviceListController.services.isEmpty) {
                    return const HomeShimmer();
                  }

                  // ─── Error State ────────────────────────────────────────────
                  if (serviceListController.errorMessage != null &&
                      serviceListController.services.isEmpty) {
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
                              'Unable to load services',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Please check your internet connection and try again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            GestureDetector(
                              onTap: () =>
                                  serviceListController.getAllServices(),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 28.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  'Try Again',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final services = serviceListController.services;

                  // ─── Empty State ─────────────────────────────────────────────
                  if (services.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 60.sp,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No services available',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'No services found at the moment. Pull down to refresh.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Distribute data
                  final originalProjects = services.take(6).toList();
                  final availableNow = services
                      .where((s) => s.isActive == true)
                      .toList();
                  final trendingProjects = [...services]
                    ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));

                  return RefreshIndicator(
                    color: Colors.black,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      await serviceListController.getAllServices();
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 10.h),
                          // Original Projects Section
                          _buildHorizontalSection(
                            title: 'Original Projects',
                            items: originalProjects,
                          ),
                          SizedBox(height: 10.h),
                          // Available Right Now Section
                          _buildHorizontalSection(
                            title: 'Available Right Now',
                            items: availableNow,
                            showAvailability: true,
                          ),
                          SizedBox(height: 10.h),
                          // Trending Projects Section
                          _buildHorizontalSection(
                            title: 'Trending Projects',
                            items: trendingProjects,
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
