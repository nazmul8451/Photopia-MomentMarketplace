import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/subscription_plan_model.dart';
import 'package:photopia/features/provider/widgets/provider_custom_bottom_nav_bar.dart';
import 'package:photopia/features/provider/screen/BottomNavigationBar/bottom_navigation_screen.dart';

class ProviderSubscriptionScreen extends StatefulWidget {
  const ProviderSubscriptionScreen({super.key});

  static const String name = "/provider-subscription";

  @override
  State<ProviderSubscriptionScreen> createState() => _ProviderSubscriptionScreenState();
}

class _ProviderSubscriptionScreenState extends State<ProviderSubscriptionScreen> {
  late Future<SubscriptionPlanModel?> _plansFuture;

  @override
  void initState() {
    super.initState();
    _plansFuture = _fetchPlans();
  }

  Future<SubscriptionPlanModel?> _fetchPlans() async {
    final response = await NetworkCaller.getRequest(url: Urls.subscriptionPlans);
    if (response.isSuccess && response.body != null) {
      return SubscriptionPlanModel.fromJson(response.body!);
    }
    return null;
  }

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
      body: FutureBuilder<SubscriptionPlanModel?>(
        future: _plansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }

          if (snapshot.hasError || snapshot.data == null || snapshot.data?.data == null || snapshot.data!.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    'No subscription plans available',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _plansFuture = _fetchPlans()),
                    child: const Text('Retry', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            );
          }

          // Use the first plan for the featured card (as in the screenshot)
          final plan = snapshot.data!.data!.first;

          return SingleChildScrollView(
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
                            plan.name ?? 'Premium Plan',
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
                        '${plan.description}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '${plan.formattedPrice}${plan.formattedInterval}',
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
                if (plan.features != null && plan.features!.isNotEmpty) ...[
                  Text(
                    'Premium Benefits',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  
                  ...plan.features!.map((benefit) => _buildBenefitItem(benefit)),
                ],
                
                SizedBox(height: 40.h),
                
                // Cancel Subscription (or action button)
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
          );
        },
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.black, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              benefit,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
