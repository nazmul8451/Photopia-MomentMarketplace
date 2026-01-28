import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/BottomNavigation.dart';
import 'package:get_storage/get_storage.dart';

class OnboardingScreen extends StatefulWidget {
  final String userRole; // 'client' or 'provider'
  
  const OnboardingScreen({super.key, this.userRole = 'client'});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Find Top Photography & Video Professionals',
      'description': 'Connect with thousands of talented photographers and videographers for any occasion',
      'image': 'assets/images/onboard_container1.png',
    },
    {
      'title': 'Browse & Discover Creative Services',
      'description': 'Explore an inspiring feed of stunning portfolios and find the perfect match for your project',
      'image': 'assets/images/onboard_container2.png',
    },
    {
      'title': 'Book & Collaborate Seamlessly',
      'description': 'Chat in real-time, schedule sessions, and manage everything from one simple platform',
      'image': 'assets/images/onboard_container3.png',
    },
    {
      'title': 'Secure & Transparent Payments',
      'description': 'All payments are protected with bank-level security. No unexpected fees, no hidden charges',
      'image': 'assets/images/onboard_container5.png',
    },
    {
      'title': 'Premium Quality, Trusted Results',
      'description': 'Read reviews, check ratings, and hire verified professionals with confidence',
      'image': 'assets/images/onboard_container4.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Onboarding Content (Image + Text)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildPage(index);
                },
              ),
            ),
            
            // Fixed Bottom Section (Dots + Button)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  // Next Button
                  GestureDetector(
                    onTap: () {
                      if (_currentPage < _onboardingData.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        // Mark as seen
                        final box = GetStorage();
                        box.write('is_first_time', false);

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
                      width: double.infinity,
                      height:  50.h.clamp(50, 50),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(28).r,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _onboardingData.length - 1 
                              ? 'Get Started' 
                              : 'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp.clamp(16,17),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(Icons.arrow_forward_ios, size: 12.sp, color: Colors.white),
                        ],
                      ),
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

  Widget _buildPage(int index) {
    final data = _onboardingData[index];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // Image Section (Direct Container)
          Expanded(
            flex: 9,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35).r,
                    image: DecorationImage(
                      image: AssetImage(data['image']!),
                      fit: BoxFit.cover,
                    ),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black.withOpacity(0.08),
                    //     blurRadius: 20,
                    //     offset: const Offset(0, 10),
                    //   ),
                    // ],
                  ),
                ),
              ),
            ),
          ),
          
          SizedBox(height: 60.h),
          
          // Text Content Section (Fixed Flex)
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Text(
                  data['title']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp.clamp(24, 25),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1E1E1E),
                    height: 1.25,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Text(
                    data['description']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp.clamp(15, 16),
                      color: Colors.grey[700],
                      height: 1.5,
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

  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 6.h,
      width: isActive ? 24.w : 6.w,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E1E1E) : const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(3).r,
      ),
    );
  }
}
