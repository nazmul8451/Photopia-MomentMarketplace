import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/provider/subscription_controller.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubscriptionController>(context, listen: false).fetchPlans();
    });
  }

  Future<void> _handleSubscription(SubscriptionPlanData plan) async {
    final controller = Provider.of<SubscriptionController>(context, listen: false);
    
    final success = await controller.createSubscription(context, plan.sId!);
    
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription successful! You are now a Pro member.'),
            backgroundColor: Colors.green,
          ),
        );
        // Optionally navigate or refresh profile
      }
    } else if (controller.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      body: Consumer<SubscriptionController>(
        builder: (context, controller, child) {
          if (controller.isLoading && (controller.planModel == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null && controller.planModel == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  Text(
                    controller.errorMessage ?? 'Something went wrong',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () => controller.fetchPlans(),
                    child: const Text('Retry', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            );
          }

          final plans = controller.planModel?.data ?? [];
          if (plans.isEmpty) {
            return Center(
              child: Text(
                'No subscription plans available',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
            );
          }

          // Use the first plan for the featured card
          final plan = plans.first;

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${plan.formattedPrice}${plan.formattedInterval}',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // Conditional Button or Status
                          if (controller.isAlreadySubscribed)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Active',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: controller.isLoading 
                                  ? null 
                                  : () => _handleSubscription(plan),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: controller.isLoading 
                                ? SizedBox(
                                    width: 16.sp,
                                    height: 16.sp,
                                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Subscribe Now'),
                            ),
                        ],
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
                
                // Bottom link/info
                Center(
                  child: GestureDetector(
                    onTap: () => _showTermsModal(context),
                    child: Text(
                      'View Terms & Conditions',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13.sp,
                        decoration: TextDecoration.underline,
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

  void _showTermsModal(BuildContext context) async {
    final controller = Provider.of<SubscriptionController>(context, listen: false);
    
    // Show loading while fetching
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await controller.fetchTermsAndConditions();
    
    if (context.mounted) {
      Navigator.pop(context); // Close loading

      if (controller.errorMessage != null && controller.termsContent == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controller.errorMessage!)),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Terms & Conditions'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(
                controller.termsContent ?? 'No content available',
                style: TextStyle(fontSize: 14.sp, height: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.black)),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
      );
    }
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
