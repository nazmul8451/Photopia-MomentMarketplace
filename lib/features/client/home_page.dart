import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/widgets/home_header.dart';
import 'package:photopia/features/client/widgets/category_bar.dart';
import 'package:photopia/features/client/widgets/section_header.dart';
import 'package:photopia/features/client/widgets/horizontal_project_card.dart';
import 'package:photopia/features/client/category_details_screen.dart';

import 'package:photopia/features/client/service_details_screen.dart';
import 'package:flutter/services.dart';

import 'dart:async';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  static const String name = "/home-page";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = true;
  int _selectedCategoryIndex = 0;
  final ScrollController _scrollController = ScrollController();

  // Mock data for different sections
  final List<Map<String, dynamic>> _originalProjects = [
    {
      'title': 'Luxury Wedding Photography',
      'imageUrl': 'assets/images/img1.png',
      'providerName': 'Sarah Photography',
      'rating': 4.8,
      'subtitle': 'Sarah Photography',
    },
    {
      'title': 'Portrait Session',
      'imageUrl': 'assets/images/img2.png',
      'providerName': 'John Studios',
      'rating': 4.9,
      'subtitle': 'John Studios',
    },
    {
      'title': 'Home Decor Shoots',
      'imageUrl': 'assets/images/img3.png',
      'providerName': 'Creative Lens',
      'rating': 4.7,
      'subtitle': 'Creative Lens',
    },
    {
      'title': 'Product Photography',
      'imageUrl': 'assets/images/img4.png',
      'providerName': 'Pro Shots',
      'rating': 4.6,
      'subtitle': 'Pro Shots',
    },
  ];

  final List<Map<String, dynamic>> _availableNow = [
    {
      'title': 'Event Photography',
      'imageUrl': 'assets/images/img5.png',
      'providerName': 'Quick Capture',
      'rating': 4.5,
      'isAvailable': true,
      'subtitle': 'Quick Capture',
    },
    {
      'title': 'Fashion Photography',
      'imageUrl': 'assets/images/img6.png',
      'providerName': 'Style Shots',
      'rating': 4.8,
      'isAvailable': true,
      'subtitle': 'Style Shots',
    },
    {
      'title': 'Corporate Headshots',
      'imageUrl': 'assets/images/img1.png',
      'providerName': 'Business Pro',
      'rating': 4.7,
      'isAvailable': true,
      'subtitle': 'Business Pro',
    },
  ];

  final List<Map<String, dynamic>> _trendingProjects = [
    {
      'title': 'Outdoor Photography',
      'imageUrl': 'assets/images/img3.png',
      'providerName': 'Nature Lens',
      'rating': 4.9,
      'likeCount': 1250,
      'subtitle': 'Nature Lens',
    },
    {
      'title': 'Baby Photography',
      'imageUrl': 'assets/images/img4.png',
      'providerName': 'Little Moments',
      'rating': 4.8,
      'likeCount': 980,
      'subtitle': 'Little Moments',
    },
    {
      'title': 'Food Photography',
      'imageUrl': 'assets/images/img2.png',
      'providerName': 'Tasty Shots',
      'rating': 4.7,
      'likeCount': 2100,
      'subtitle': 'Tasty Shots',
    },
    {
      'title': 'Architecture Photography',
      'imageUrl': 'assets/images/img5.png',
      'providerName': 'Urban Views',
      'rating': 4.6,
      'likeCount': 750,
      'subtitle': 'Urban Views',
    },
  ];

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    // Infinite scroll listener
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
      // Load more content here (for future API integration)
      // For now, we're using static mock data
    }
  }

  void _navigateToCategoryDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CategoryDetailsScreen()),
    );
  }

  void _navigateToServiceDetails(
    BuildContext context,
    Map<String, dynamic> service,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ServiceDetailsScreen(service: service),
      ),
    );
  }

  Widget _buildHorizontalSection({
    required String title,
    required List<Map<String, dynamic>> items,
    bool showAvailability = false,
    bool showLikes = false,
  }) {
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
                imageUrl: item['imageUrl'],
                title: item['title'],
                providerName: item['providerName'],
                rating: item['rating'],
                isAvailable: showAvailability && (item['isAvailable'] ?? false),
                likeCount: showLikes ? item['likeCount'] : null,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HomeHeader(),
                  CategoryBar(
                    isLoading: _isLoading,
                    selectedIndex: _selectedCategoryIndex,
                    onCategorySelected: (index) {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                  ),
                  SizedBox(height: 15.h),
                ],
              ),
            ),
            // Scrollable Content with Horizontal Sections
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    )
                  : SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: 10.h),
                          // Original Projects Section
                          _buildHorizontalSection(
                            title: 'Original Projects',
                            items: _originalProjects,
                          ),
                          SizedBox(height: 10.h),
                          // Available Right Now Section
                          _buildHorizontalSection(
                            title: 'Available Right Now',
                            items: _availableNow,
                            showAvailability: true,
                          ),
                          SizedBox(height: 10.h),
                          // Trending Projects Section
                          _buildHorizontalSection(
                            title: 'Trending Projects',
                            items: _trendingProjects,
                            showLikes: true,
                          ),
                          SizedBox(
                            height: 100.h,
                          ), // Bottom padding for navigation bar
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
