import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/widgets/home_header.dart';
import 'package:photopia/features/client/widgets/category_bar.dart';
import 'package:photopia/features/client/widgets/photo_card.dart';
import 'package:photopia/features/client/category_details_screen.dart';

import 'package:flutter/services.dart';

import 'dart:async';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  static const String name = "/home-page";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = true;

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
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CategoryDetailsScreen(),
      ),
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
                  const HomeHeader(),
                  CategoryBar(isLoading: _isLoading),
                  SizedBox(height: 15.h),
                ],
              ),
            ),
            // Scrollable Grid Content
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.h,
                        crossAxisSpacing: 15.w,
                        childAspectRatio: 0.80,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (_isLoading) {
                            return const PhotoCard(isLoading: true);
                          }
                          final List<Map<String, dynamic>> photos = [
                            {
                              'title': 'Interior Photography for your home',
                              'imageUrl': 'assets/images/img1.png',
                            },
                            {
                              'title': 'Portrait Photography',
                              'imageUrl': 'assets/images/img2.png',
                              'hasBadges': true,
                            },
                            {
                              'title': 'Home Decor Shoots',
                              'imageUrl': 'assets/images/img3.png',
                            },
                            {
                              'title': 'Product Photography',
                              'imageUrl': 'assets/images/img4.png',
                            },
                            {
                              'title': 'Outdoor Photography',
                              'imageUrl': 'assets/images/img5.png',
                            },
                            {
                              'title': 'Fashion Photography',
                              'imageUrl': 'assets/images/img6.png',
                            },
                          ];
                          final photo = photos[index % photos.length];
                          return GestureDetector(
                            onTap: () => _navigateToDetails(context),
                            child: PhotoCard(
                              title: photo['title'],
                              imageUrl: photo['imageUrl'],
                              hasBadges: photo['hasBadges'] ?? false,
                            ),
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
