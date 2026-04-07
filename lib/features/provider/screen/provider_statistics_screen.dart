import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:photopia/controller/provider/wallet_controller.dart';
import 'package:photopia/controller/provider/provider_profile_controller.dart';
import 'package:photopia/controller/provider/statistics_controller.dart';
import 'package:photopia/core/widgets/subscription_badge.dart';
import 'package:photopia/data/models/statistics_model.dart';
import 'package:photopia/features/provider/screen/provider_subscription_screen.dart';
import 'package:provider/provider.dart';

class ProviderStatisticsScreen extends StatefulWidget {
  const ProviderStatisticsScreen({super.key});

  @override
  State<ProviderStatisticsScreen> createState() => _ProviderStatisticsScreenState();
}

class _ProviderStatisticsScreenState extends State<ProviderStatisticsScreen> {
  String selectedFilter = 'Month';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletController>().getMyWallet();
      context.read<StatisticsController>().fetchStatistics();
    });
  }

  Future<void> _handleRefresh() async {
    // Refresh the relevant data controllers
    await Future.wait([
      context.read<WalletController>().getMyWallet(),
      context.read<StatisticsController>().fetchStatistics(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              'Statistics',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.w),
            Consumer<ProviderProfileController>(
              builder: (context, profileController, child) {
                return SubscriptionBadge(
                  isSubscribed: profileController.userProfile?.isSubscribed ?? false,
                );
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.black,
        backgroundColor: Colors.white,
        child: Consumer<StatisticsController>(
          builder: (context, controller, child) {
            final stats = controller.statisticsData;
            
            if (controller.isLoading && stats == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Top Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          icon: Icons.visibility_outlined,
                          label: 'Profile Views',
                          value: '${stats?.profileViews?.count ?? 0}',
                          subValue: '${stats?.profileViews?.change ?? 0}% this week',
                          isPositive: (stats?.profileViews?.change ?? 0) >= 0,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildSummaryCard(
                          icon: Icons.star_outline_rounded,
                          label: 'Rating',
                          value: '${stats?.rating?.score ?? 0}',
                          subValue: '${stats?.rating?.reviews ?? 0} reviews',
                          isPositive: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Views vs Category Comparison
                  _buildComparisonCard(
                    title: 'Views vs Category Average',
                    icon: Icons.trending_up,
                    myData: stats?.profileViews?.count ?? 0,
                    avgData: stats?.profileViews?.performanceVsCategory?.categoryAverage ?? 0,
                    unit: '',
                    myLabel: 'Your Views',
                    avgLabel: 'Category Average',
                    statusText: stats?.profileViews?.performanceVsCategory?.percentageAbove != null 
                      ? 'You\'re performing ${stats!.profileViews!.performanceVsCategory!.percentageAbove}% ${stats.profileViews!.performanceVsCategory!.percentageAbove! >= 0 ? "above" : "below"} category average'
                      : 'N/A',
                  ),
                  SizedBox(height: 24.h),

                  // Rating vs Category Comparison
                  _buildComparisonCard(
                    title: 'Rating vs Category Average',
                    icon: Icons.star_border_rounded,
                    myData: stats?.rating?.score ?? 0,
                    avgData: stats?.rating?.performanceVsCategory?.categoryAverage ?? 0,
                    unit: '',
                    myLabel: 'Your Rating',
                    avgLabel: 'Category Average',
                    statusText: stats?.rating?.performanceVsCategory?.percentageHigher != null
                      ? 'Your rating is ${stats!.rating!.performanceVsCategory!.percentageHigher}% higher than similar providers'
                      : 'N/A',
                    extraText: '(${stats?.rating?.reviews ?? 0} reviews)',
                  ),
                  SizedBox(height: 24.h),

                  // Regional Views
                  _buildRegionCard(stats?.viewsByRegion ?? []),
                  SizedBox(height: 24.h),

                  // Revenue Analytics
                  _buildRevenueCard(stats?.revenueAnalytics),
                  SizedBox(height: 24.h),

                  // Export Data Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: controller.isExporting 
                        ? null 
                        : () async {
                            final path = await controller.exportStatistics();
                            if (path != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Report saved to: ${path.split("/").last}'),
                                  backgroundColor: Colors.black,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          },
                      icon: controller.isExporting 
                        ? SizedBox(
                            width: 16.w, 
                            height: 16.w, 
                            child: const CircularProgressIndicator(strokeWidth: 2)
                          )
                        : Icon(Icons.download_outlined, size: 20.sp),
                      label: Text(
                        controller.isExporting ? 'Exporting...' : 'Export Full Report',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required String subValue,
    required bool isPositive,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: Colors.grey),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              if (!isPositive)
                Icon(Icons.trending_down, size: 14.sp, color: Colors.red),
              SizedBox(width: 4.w),
              Text(
                subValue,
                style: TextStyle(
                  color: isPositive ? Colors.grey : Colors.red,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard({
    required String title,
    required IconData icon,
    required num myData,
    required num avgData,
    required String unit,
    required String myLabel,
    required String avgLabel,
    required String statusText,
    String? extraText,
  }) {
    double total = (myData > avgData ? myData : avgData).toDouble();
    if (total == 0) total = 1;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.sp, color: Colors.black),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          
          // My Data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(myLabel, style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$unit$myData',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    if (extraText != null)
                      TextSpan(
                        text: ' $extraText',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11.sp,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: myData / total,
              minHeight: 8.h,
              backgroundColor: const Color(0xFFF1F3F5),
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),

          // Avg Data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(avgLabel, style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
              Text(
                '$unit$avgData',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: avgData / total,
              minHeight: 8.h,
              backgroundColor: const Color(0xFFF1F3F5),
              color: Colors.grey.shade300,
            ),
          ),
          SizedBox(height: 16.h),

          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEDFCF2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, size: 16.sp, color: const Color(0xFF12B76A)),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: const Color(0xFF027A48),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionCard(List<RegionStats> regions) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18.sp, color: Colors.black),
              SizedBox(width: 8.w),
              Text(
                'Profile Views by Region',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (regions.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: const Center(child: Text('No regional data available')),
            )
          else
            ...regions.map((reg) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reg.city ?? 'Unknown',
                          style: TextStyle(fontSize: 13.sp, color: Colors.black),
                        ),
                      ),
                      Text(
                        '${reg.percentage ?? 0}%',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '${reg.count ?? 0}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: LinearProgressIndicator(
                      value: (reg.percentage ?? 0) / 100,
                      minHeight: 6.h,
                      backgroundColor: const Color(0xFFF1F3F5),
                      color: const Color(0xFF344054),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              );
            }),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Views',
                style: TextStyle(color: Colors.grey, fontSize: 13.sp),
              ),
              Text(
                '${regions.fold(0, (sum, item) => sum + (item.count ?? 0))}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(RevenueAnalytics? revenue) {
    final filters = ['Week', 'Month', 'Quarter', 'Year'];
    // JSON shown by user currently has empty weeklyBreakdown, but we model for potential use
    final weeks = (revenue?.weeklyBreakdown ?? []).isNotEmpty 
      ? revenue!.weeklyBreakdown! 
      : [
          {'name': 'Week 1', 'amount': 0, 'max': 100},
          {'name': 'Week 2', 'amount': 0, 'max': 100},
          {'name': 'Week 3', 'amount': 0, 'max': 100},
          {'name': 'Week 4', 'amount': 0, 'max': 100},
        ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.euro, size: 18.sp, color: Colors.black),
              SizedBox(width: 8.w),
              Text(
                'Revenue Analytics',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Filters
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(12).r,
            ),
            child: Row(
              children: filters.map((f) {
                bool isSelected = selectedFilter == f;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedFilter = f),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.transparent,
                        borderRadius: BorderRadius.circular(10).r,
                      ),
                      child: Text(
                        f,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontSize: 13.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Month',
                      style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                    ),
                    Row(
                      children: [
                        Icon(
                          (revenue?.percentageChange ?? 0) >= 0 ? Icons.trending_up : Icons.trending_down, 
                          size: 16.sp, 
                          color: (revenue?.percentageChange ?? 0) >= 0 ? const Color(0xFF12B76A) : Colors.red
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${(revenue?.percentageChange ?? 0) >= 0 ? "+" : ""}${revenue?.percentageChange ?? 0}%',
                          style: TextStyle(
                            color: (revenue?.percentageChange ?? 0) >= 0 ? const Color(0xFF12B76A) : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  '€${revenue?.currentMonth ?? 0}',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'vs previous month: €${revenue?.previousMonth ?? 0}',
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          ...weeks.map((w) {
            // Support both Map and potentially dynamic objects if model changes
            final name = w is Map ? w['name'] : 'N/A';
            final amount = w is Map ? w['amount'] : 0;
            final max = w is Map ? (w['max'] ?? 100) : 100;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$name', style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
                    Text(
                      '€$amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: (amount as num) / (max as num),
                    minHeight: 10.h,
                    backgroundColor: const Color(0xFFF1F3F5),
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            );
          }),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Average per period', style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
                  SizedBox(height: 4.h),
                  Text('€${revenue?.averagePerPeriod ?? 0}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Best performing', style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
                  SizedBox(height: 4.h),
                  Text('€${revenue?.bestPerforming ?? 0}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
