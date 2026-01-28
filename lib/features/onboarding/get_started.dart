import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_sizes.dart';
import 'package:get_storage/get_storage.dart';
import 'package:photopia/features/client/BottomNavigation.dart';
import 'package:photopia/features/onboarding/onboarding_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(30.w),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/app_name.png',
                  height: 50.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 50.h,),              // Button
                // Subtitle
                Text(
                  'Connect with the world\'s best\nphotography & video professionals',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black87,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 50.h,),              // Button
                GestureDetector(
                  onTap: () {
                    // Check if first time user
                    bool isFirstTime = box.read('is_first_time') ?? true;
                    
                    if (isFirstTime) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OnboardingScreen(userRole: 'client'),
                        ),
                      );
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BottomNavigationScreen(),
                        ),
                         (route) => false,
                      );
                    }
                  },
                  child: Container(
                    width:200.w,
                    height: AppSizes.fieldHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(25.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp.clamp(15, 16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
