import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectPackageScreen extends StatefulWidget {
  const SelectPackageScreen({super.key});

  @override
  State<SelectPackageScreen> createState() => _SelectPackageScreenState();
}

class _SelectPackageScreenState extends State<SelectPackageScreen> {
  int _selectedPackageIndex = 0;

  // This list can be easily moved to a controller or fetched from an API
  final List<Map<String, dynamic>> _packages = [
    {
      'name': 'Basic Package',
      'price': '800',
      'currency': '€',
      'duration': '4 hours',
      'features': [
        '200 edited photos',
        'Online gallery',
        '1 photographer',
        'Basic retouching',
      ],
    },
    {
      'name': 'Standard Package',
      'price': '1,500',
      'currency': '€',
      'duration': '8 hours',
      'features': [
        '400 edited photos',
        'Online gallery + USB',
        '1 photographer + assistant',
        'Advanced retouching',
        'Engagement shoot included',
      ],
    },
    {
      'name': 'Premium Package',
      'price': '2,500',
      'currency': '€',
      'duration': 'Full day',
      'features': [
        'Unlimited edited photos',
        'Premium album + USB',
        '2 photographers',
        'Professional retouching',
        'Engagement shoot',
        'Drone coverage',
        'Same-day highlights',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select a Package',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp.clamp(18, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 120.h),
            itemCount: _packages.length,
            itemBuilder: (context, index) {
              final package = _packages[index];
              final isSelected = _selectedPackageIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPackageIndex = index;
                  });
                },
                child: _buildPackageCard(package, isSelected),
              );
            },
          ),
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

  Widget _buildPackageCard(Map<String, dynamic> package, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16).r,
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                package['name'],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 16.sp.clamp(16, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${package['currency']}${package['price']}',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 16.sp.clamp(16, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            package['duration'],
            style: TextStyle(
              color: isSelected ? Colors.white70 : Colors.grey[600],
              fontSize: 13.sp.clamp(13, 14),
            ),
          ),
          SizedBox(height: 20.h),
          ...List.generate(
            (package['features'] as List).length,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16.sp,
                    color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF4CAF50).withOpacity(0.6),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      package['features'][i],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 13.sp.clamp(13, 14),
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
                    fontSize: 14.sp.clamp(14, 18),
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
