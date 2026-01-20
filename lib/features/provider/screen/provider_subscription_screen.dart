import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/provider/widgets/provider_custom_bottom_nav_bar.dart';
import 'package:photopia/features/provider/screen/BottomNavigationBar/bottom_navigation_screen.dart';

class ProviderSubscriptionScreen extends StatelessWidget {
  const ProviderSubscriptionScreen({super.key});

  static const String name = "/provider-subscription";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Subscription',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            // Premium Plan Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7), // Light yellow
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFFFB300), width: 1), // Amber/Gold border
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.workspace_premium, color: const Color(0xFFFFB300), size: 24.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Premium Plan',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Active until January 20, 2026',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '\$16/month',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            
            // Benefits Section
            Text(
              'Premium Benefits',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.h),
            
            _buildBenefitItem('Priority in search results'),
            _buildBenefitItem('Featured profile badge'),
            _buildBenefitItem('Unlimited portfolio photos'),
            _buildBenefitItem('Advanced analytics'),
            _buildBenefitItem('Custom booking forms'),
            _buildBenefitItem('Priority customer support'),
            
            SizedBox(height: 40.h),
            
            // Cancel Subscription
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Implement cancel subscription logic
                },
                child: Text(
                  'Cancel Subscription',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
      bottomNavigationBar: null,
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.black, size: 20.sp),
          SizedBox(width: 12.w),
          Text(
            benefit,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
