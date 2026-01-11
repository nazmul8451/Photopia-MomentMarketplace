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
          Padding(
            padding: EdgeInsets.all(12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                ShimmerSkeleton(width: 100.w, height: 14.h),
                SizedBox(height: 8.h),
                // Subtitle skeleton
                ShimmerSkeleton(width: 80.w, height: 12.h),
                SizedBox(height: 12.h),
                // Rating skeleton
                Row(
                  children: [
                    ShimmerSkeleton(width: 40.w, height: 12.h),
                    SizedBox(width: 8.w),
                    ShimmerSkeleton(width: 30.w, height: 12.h),
                  ],
                ),
                SizedBox(height: 12.h),
                // Price skeleton
                ShimmerSkeleton(width: 60.w, height: 14.h),
              ],
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
