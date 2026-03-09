import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ProviderOverviewShimmer extends StatelessWidget {
  const ProviderOverviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          // Status Tabs Shimmer
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 12.w),
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          // Listing Cards Shimmer
          ...List.generate(3, (index) => _buildListingCardShimmer()),
          SizedBox(height: 20.h),
          // Statistics Shimmer
          _buildStatisticsShimmer(),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildListingCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 150.w, height: 18.h, color: Colors.white),
                Container(width: 60.w, height: 20.h, color: Colors.white),
              ],
            ),
            SizedBox(height: 8.h),
            Container(width: 100.w, height: 14.h, color: Colors.white),
            SizedBox(height: 16.h),
            Row(
              children: [
                Container(width: 80.w, height: 14.h, color: Colors.white),
                SizedBox(width: 16.w),
                Container(width: 80.w, height: 14.h, color: Colors.white),
              ],
            ),
            SizedBox(height: 16.h),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: Container(height: 30.h, color: Colors.white),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(height: 30.h, color: Colors.white),
                ),
                SizedBox(width: 12.w),
                Container(width: 40.w, height: 30.h, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 140.w, height: 20.h, color: Colors.white),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                4,
                (index) => Column(
                  children: [
                    Container(width: 40.w, height: 12.h, color: Colors.white),
                    SizedBox(height: 8.h),
                    Container(width: 30.w, height: 18.h, color: Colors.white),
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
