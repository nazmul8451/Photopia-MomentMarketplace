import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/authentication/log_in_screen.dart';

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
      'image': 'assets/images/page_viewimg1.png',
      'icon': 'camera_alt',
    },
    {
      'title': 'Browse & Discover Creative Services',
      'description': 'Explore an inspiring feed of stunning portfolios and find the perfect match for your project',
      'image': 'assets/images/page_viewimg2.png',
      'icon': 'search',
    },
    {
      'title': 'Book & Collaborate Seamlessly',
      'description': 'Chat in real-time, schedule sessions, and manage everything from one simple platform',
      'image': 'assets/images/page_viewimg3.png',
      'icon': 'chat_bubble_outline',
    },
    {
      'title': 'Secure & Transparent Payments',
      'description': 'All payments are protected with bank-level security. No unexpected fees, no hidden charges',
      'image': 'assets/images/pageview_img4.png',
      'icon': 'security',
    },
    {
      'title': 'Premium Quality, Trusted Results',
      'description': 'Read reviews, check ratings, and hire verified professionals with confidence',
      'image': 'assets/images/page_viewimg5.png',
      'icon': 'star_outline',
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
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
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
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogInScreen(userRole: widget.userRole),
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
    IconData getIcon(String? name) {
      switch (name) {
        case 'camera_alt': return Icons.camera_alt_outlined;
        case 'search': return Icons.search_outlined;
        case 'chat_bubble_outline': return Icons.chat_bubble_outline;
        case 'security': return Icons.shield_outlined;
        case 'star_outline': return Icons.star_outline;
        default: return Icons.check;
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // Image Section (Fixed Flex)
          Expanded(
            flex: 6,
            child: Center(
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  // Image
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35).r,
                        image: DecorationImage(
                          image: AssetImage(data['image']!),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Overlapping Icon
                  Positioned(
                    bottom: -1.r,
                    child: Container(
                      width: 60.r,
                      height: 60.r,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16).r,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16).r,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            alignment: Alignment.center,
                            child: Icon(
                              getIcon(data['icon']),
                              color: Colors.white,
                              size: 28.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 60.h),
          
          // Text Content Section (Fixed Flex)
          Expanded(
            flex: 4,
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
