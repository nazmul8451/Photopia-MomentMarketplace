import 'package:flutter/material.dart';
import 'dart:async';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';
import 'package:photopia/features/client/widgets/category_bar.dart';
import 'package:photopia/features/client/widgets/search_header.dart';
import 'package:photopia/features/client/widgets/service_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

class CategoryDetailsScreen extends StatefulWidget {
  const CategoryDetailsScreen({super.key});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate data loading
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
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
            Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(15).r,
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
                  SearchHeader(
                    onFilterApplied: (filters) {
                      // Handle filtering logic here
                      setState(() {
                        _isLoading = true;
                      });
                      // Simulate fetching filtered data
                      Timer(const Duration(seconds: 1), () {
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                            // In a real app, you'd update your data list based on 'filters'
                          });
                        }
                      });
                    },
                  ),
              
                  SizedBox(height: 5.h),
                ],
              ),
            ),
            // Scrollable Grid Results
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 15.h,
                        crossAxisSpacing: 15.w,
                        childAspectRatio:
                            0.55, // Increased height for iPhone/Small screens
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (_isLoading) {
                            return const ServiceCardSkeleton();
                          }
                          // Mock data for services
                          final List<Map<String, dynamic>> services = [
                            {
                              'title': 'Romantic Wedding Shoot',
                              'subtitle': 'Emma Wilson',
                              'imageUrl':
                                  'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=500',
                              'rating': 4.9,
                              'reviews': 127,
                              'priceRange': '€800 - €2,500',
                              'tags': ['Wedding', 'Outdoor', 'Luxury'],
                              'isPremium': true,
                            },
                            {
                              'title': 'Professional Portrait',
                              'subtitle': 'Marco Silva',
                              'imageUrl':
                                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=500',
                              'rating': 4.8,
                              'reviews': 89,
                              'priceRange': '€150 - €500',
                              'tags': ['Portrait', 'Studio', 'Business'],
                              'isPremium': false,
                            },
                            {
                              'title': 'Corporate Video',
                              'subtitle': 'Tech Media Studio',
                              'imageUrl':
                                  'https://images.unsplash.com/photo-1492724441997-5dc865305da7?q=80&w=500',
                              'rating': 5.0,
                              'reviews': 45,
                              'priceRange': '€1,200 - €4,000',
                              'tags': ['Corporate', 'Video', 'Event'],
                              'isPremium': false,
                            },
                            {
                              'title': 'Aerial Drone Photo',
                              'subtitle': 'SkyView Productions',
                              'imageUrl':
                                  'https://images.unsplash.com/photo-1508614589041-895b88991e3e?q=80&w=500',
                              'rating': 4.9,
                              'reviews': 62,
                              'priceRange': '€300 - €1,500',
                              'tags': ['Drone', 'Aerial', 'Landscape'],
                              'isPremium': true,
                            },
                          ];
                          final service = services[index % services.length];
                          return ServiceCard(
                            title: service['title'],
                            subtitle: service['subtitle'],
                            imageUrl: service['imageUrl'],
                            rating: service['rating'],
                            reviews: service['reviews'],
                            priceRange: service['priceRange'],
                            tags: service['tags'],
                            isPremium: service['isPremium'],
                          );
                        },
                        childCount: _isLoading ? 6 : 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
