import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Scrollable Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Media Section
                _buildTopMedia(),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      // Title
                      Text(
                        widget.service['title'] ?? 'Romantic Wedding Photography',
                        style: TextStyle(
                          fontSize: 20.sp.clamp(20, 22),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      
                      SizedBox(height: 20.h),
                      // Provider Section
                      Text(
                        'Provider',
                        style: TextStyle(
                          fontSize: 14.sp.clamp(14, 16),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildProviderCard(),
                      
                      SizedBox(height: 20.h),
                      // Stats Row
                      _buildStatsRow(),
                      
                      SizedBox(height: 25.h),
                      // About Section
                      _buildSectionTitle('About'),
                      SizedBox(height: 8.h),
                      Text(
                        'Capturing your most precious moments with artistic vision and professional expertise. Specializing in romantic, candid wedding photography that tells your unique love story.',
                        style: TextStyle(
                          fontSize: 13.sp.clamp(13, 14),
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      
                      SizedBox(height: 25.h),
                      // Equipment Section
                      Row(
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 20.sp, color: Colors.black87),
                          SizedBox(width: 8.w),
                          _buildSectionTitle('Equipment'),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _buildEquipmentTags(),
                      
                      SizedBox(height: 25.h),
                      // Portfolio Section
                      _buildSectionTitle('Portfolio'),
                      SizedBox(height: 12.h),
                      _buildPortfolioGrid(),
                      
                      SizedBox(height: 25.h),
                      // Extra Tags Section
                      _buildBottomTags(),
                      
                      SizedBox(height: 120.h), // Space for sticky bottom bar
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Sticky Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMedia() {
    final List<String> images = [
      widget.service['imageUrl'] ?? 'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=500',
      'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=500',
      'https://images.unsplash.com/photo-1583939003579-730e3918a45a?q=80&w=500',
    ];

    return Stack(
      children: [
        Container(
          height: 380.h,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        // Play Icon Overlay
        Positioned.fill(
          child: Center(
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow, color: Colors.white, size: 30.sp),
            ),
          ),
        ),
        // Dots Indicator
        Positioned(
          bottom: 20.h,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                ),
              );
            }),
          ),
        ),
        // Custom App Bar Overlay
        Positioned(
          top: MediaQuery.of(context).padding.top + 10.h,
          left: 20.w,
          right: 20.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, size: 20.sp, color: Colors.black),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.bookmark_border, size: 20.sp, color: Colors.black),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.flag_outlined, size: 20.sp, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard() {
    return Row(
      children: [
        CircleAvatar(
          radius: 25.r,
          backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200'),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.service['subtitle'] ?? 'Emma Wilson',
                    style: TextStyle(
                      fontSize: 15.sp.clamp(15, 16),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20).r,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars, color: Colors.orange, size: 10.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.orange, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text(
                    '${widget.service['rating'] ?? 4.9} (${widget.service['reviews'] ?? 127} reviews)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox('Response Time', '~1 hour'),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatBox('Completed Projects', '245'),
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12).r,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildEquipmentTags() {
    final tags = ['Canon EOS R5', 'Sony A7 III', 'DJI Mavic 3', 'Professional Lighting'];
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: tags.map((tag) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8).r,
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildPortfolioGrid() {
    final images = [
      'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=300',
      'https://images.unsplash.com/photo-1519741497674-611481863552?q=80&w=300',
      'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=300',
      'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=300',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12).r,
              child: Image.network(
                images[index],
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomTags() {
    final tags = widget.service['tags'] as List<String>? ?? ['#Wedding', '#Outdoor', '#Candid', '#Portrait'];
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: tags.map((tag) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20).r,
        ),
        child: Text(
          tag.startsWith('#') ? tag : '#$tag',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12).r,
            ),
            child: Icon(Icons.chat_bubble_outline, size: 24.sp, color: Colors.black),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12).r,
              ),
              child: Center(
                child: Text(
                  'Book Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp.clamp(14.sp, 18.sp),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
