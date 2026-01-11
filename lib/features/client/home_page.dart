import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/widgets/home_header.dart';
import 'package:photopia/features/client/widgets/category_bar.dart';
import 'package:photopia/features/client/widgets/photo_card.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  static const String name = "home-page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const HomeHeader(),
                  SizedBox(height: 10.h),
                  const CategoryBar(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15.h,
                  crossAxisSpacing: 15.w,
                  childAspectRatio: 0.8, // Adjust based on text height
                ),
                delegate: SliverChildListDelegate([
                   const PhotoCard(
                    title: 'Interior Photography',
                    imageUrl: 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?q=80&w=500',
                  ),
                   const PhotoCard(
                    title: 'Portrait Photography',
                    imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=500',
                    hasBadges: true,
                  ),
                   const PhotoCard(
                    title: 'Home Decor Shoots',
                    imageUrl: 'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=500',
                  ),
                   const PhotoCard(
                    title: 'Product Photography',
                    imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=500',
                  ),
                   const PhotoCard(
                    title: 'Outdoor Photography',
                    imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=500',
                  ),
                   const PhotoCard(
                    title: 'Fashion Photography',
                    imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=500',
                  ),
                ]),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)), // Space for bottom nav
          ],
        ),
      ),
    );
  }
}