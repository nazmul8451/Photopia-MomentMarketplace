import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShimmerSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8).r,
        ),
      ),
    );
  }
}

class ServiceCardSkeleton extends StatelessWidget {
  const ServiceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16).r,
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          AspectRatio(
            aspectRatio: 1.1,
            child: ShimmerSkeleton(
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16).r),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title skeleton
                      ShimmerSkeleton(width: 100.w, height: 12.h),
                      SizedBox(height: 4.h),
                      // Subtitle skeleton
                      ShimmerSkeleton(width: 80.w, height: 10.h),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Rating skeleton
                  Row(
                    children: [
                      ShimmerSkeleton(width: 30.w, height: 10.h),
                      SizedBox(width: 8.w),
                      ShimmerSkeleton(width: 20.w, height: 10.h),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Price skeleton
                  ShimmerSkeleton(width: 60.w, height: 12.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryChipSkeleton extends StatelessWidget {
  const CategoryChipSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerSkeleton(
      width: 100.w,
      height: 35.h.clamp(35, 45),
      borderRadius: BorderRadius.circular(15).r,
    );
  }
}

class ProviderCardSkeleton extends StatelessWidget {
  const ProviderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16).r,
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ShimmerSkeleton(
                width: 60.r,
                height: 60.r,
                borderRadius: BorderRadius.circular(30).r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerSkeleton(width: 120.w, height: 16.h),
                    SizedBox(height: 8.h),
                    ShimmerSkeleton(width: 150.w, height: 12.h),
                    SizedBox(height: 8.h),
                    ShimmerSkeleton(width: 100.w, height: 12.h),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: ShimmerSkeleton(width: double.infinity, height: 40.h)),
              SizedBox(width: 12.w),
              Expanded(child: ShimmerSkeleton(width: double.infinity, height: 40.h)),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20.w, top: 10.h),
          child: ShimmerSkeleton(width: 100.w, height: 24.h),
        ),
        SizedBox(height: 15.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20).r,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                ShimmerSkeleton(
                  width: 80.w,
                  height: 80.w,
                  borderRadius: BorderRadius.circular(40).r,
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerSkeleton(width: 150.w, height: 20.h),
                      SizedBox(height: 8.h),
                      ShimmerSkeleton(width: 180.w, height: 14.h),
                      SizedBox(height: 12.h),
                      ShimmerSkeleton(width: 80.w, height: 25.h, borderRadius: BorderRadius.circular(20).r),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MessageListItemSkeleton extends StatelessWidget {
  const MessageListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      child: Row(
        children: [
          ShimmerSkeleton(
            width: 50.r,
            height: 50.r,
            borderRadius: BorderRadius.circular(25).r,
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerSkeleton(width: 100.w, height: 14.h),
                    ShimmerSkeleton(width: 40.w, height: 10.h),
                  ],
                ),
                SizedBox(height: 8.h),
                ShimmerSkeleton(width: 200.w, height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
