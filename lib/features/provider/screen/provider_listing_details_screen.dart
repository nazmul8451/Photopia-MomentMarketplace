import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/provider/widgets/provider_custom_bottom_nav_bar.dart';
import 'package:photopia/features/provider/screen/BottomNavigationBar/bottom_navigation_screen.dart';

class ProviderListingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> listing;

  const ProviderListingDetailsScreen({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Listing Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTypography.h1,
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
            // Hero Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: Image.asset(
                'assets/images/img1.png',
                height: 200.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200.h,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(Icons.image, size: 50.sp, color: Colors.grey[400]),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            
            // Title and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    listing['title'],
                    style: TextStyle(
                      fontSize: AppTypography.h1,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    listing['status'],
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            
            // Price and Duration
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  listing['rate'],
                  style: TextStyle(
                    fontSize: AppTypography.h1,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.circle, size: 4.sp, color: Colors.grey[400]),
                SizedBox(width: 8.w),
                Text(
                  '2-4 hours', 
                  style: TextStyle(
                    fontSize: AppTypography.bodyLarge,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            
            // Category Pill
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                listing['category'],
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            
            const Divider(color: Color(0xFFF0F0F0)),
            SizedBox(height: 20.h),
            
            // Description
            Text(
              'Description',
              style: TextStyle(
                fontSize: AppTypography.h2,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Capture your special events with professional photography services.',
              style: TextStyle(
                fontSize: AppTypography.bodyLarge,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 20.h),
            
            const Divider(color: Color(0xFFF0F0F0)),
            SizedBox(height: 20.h),
            
            // Location
            Text(
              'Location',
              style: TextStyle(
                fontSize: AppTypography.h2,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'New York, NY',
              style: TextStyle(
                fontSize: AppTypography.bodyLarge,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20.h),
            
            const Divider(color: Color(0xFFF0F0F0)),
            SizedBox(height: 20.h),
            
            // Stats
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing['views'].toString(),
                        style: TextStyle(
                          fontSize: AppTypography.h1,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Total Views',
                        style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing['bookings'].toString(),
                        style: TextStyle(
                          fontSize: AppTypography.h1,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Bookings',
                        style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            
            // Footer Buttons
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(0, 50.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text(
                      'Edit Listing',
                      style: TextStyle(color: Colors.white, fontSize: AppTypography.h2, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
                Container(
                  width: 50.h,
                  height: 50.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
      bottomNavigationBar: null,
    );
  }
}
