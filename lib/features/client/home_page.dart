import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/widgets/home_header.dart';
import 'package:photopia/features/client/widgets/category_bar.dart';
import 'package:photopia/features/client/widgets/photo_card.dart';

import 'package:flutter/services.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  static const String name = "home-page";

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
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HomeHeader(),
                  CategoryBar(),
                  SizedBox(height: 15),
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
                      delegate: SliverChildListDelegate([
                        const PhotoCard(
                          title: 'Interior Photography for your home',
                          imageUrl:
                              'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?q=80&w=500',
                        ),
                        const PhotoCard(
                          title: 'Portrait Photography',
                          imageUrl:
                              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=500',
                          hasBadges: true,
                        ),
                        const PhotoCard(
                          title: 'Home Decor Shoots',
                          imageUrl:
                              'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=500',
                        ),
                        const PhotoCard(
                          title: 'Product Photography',
                          imageUrl:
                              'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=500',
                        ),
                        const PhotoCard(
                          title: 'Outdoor Photography',
                          imageUrl:
                              'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=500',
                        ),
                        const PhotoCard(
                          title: 'Fashion Photography',
                          imageUrl:
                              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=500',
                        ),
                      ]),
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
