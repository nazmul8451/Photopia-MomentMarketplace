import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/core/routes/app_routes.dart';
import 'package:photopia/features/provider/screen/provider_notification_screen.dart';
import 'package:photopia/features/provider/screen/booking_details_screen.dart';
import 'package:photopia/core/widgets/custom_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ProviderOrdersScreen extends StatefulWidget {
  const ProviderOrdersScreen({super.key});

  @override
  State<ProviderOrdersScreen> createState() => _ProviderOrdersScreenState();
}

class _ProviderOrdersScreenState extends State<ProviderOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _simulateLoading();
  }

  bool _isLoading = true;

  void _simulateLoading() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/images/app_name.png',
                        height: 24.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProviderNotificationScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Icon(Icons.notifications_outlined, size: 20.sp),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: TextStyle(
                    fontSize: AppTypography.bodyLarge,
                    fontWeight: FontWeight.w600,
                  ),
                  dividerColor: Colors.transparent,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  tabs: const [
                    Tab(text: 'Today'),
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Pending'),
                  ],
                ),
              ),
            ),

            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _isLoading ? _buildShimmerLoading() : _buildTodayTab(),
                  _isLoading ? _buildShimmerLoading() : _buildUpcomingTab(),
                  _isLoading ? _buildShimmerLoading() : _buildPendingTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTab() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Bookings",
              style: TextStyle(
                fontSize: AppTypography.h1,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '2 bookings',
              style: TextStyle(
                fontSize: AppTypography.bodySmall,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        _buildTodayBookingCard(
          name: 'Marie Dubois',
          service: 'Portrait Photo Session',
          time: '10:00 - 11:30',
          location: 'Central Park, New York',
          price: '150',
          imageUrl: 'assets/images/img1.png',
          status: 'Confirmed',
        ),
        _buildTodayBookingCard(
          name: 'Jean Martin',
          service: 'Event Photography',
          time: '14:00 - 17:00',
          location: 'Grand Ballroom, Manhattan',
          price: '450',
          imageUrl: 'assets/images/img2.png',
          status: 'Confirmed',
        ),
      ],
    );
  }

  Widget _buildUpcomingTab() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Upcoming Bookings",
              style: TextStyle(
                fontSize: AppTypography.h1,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '3 bookings',
              style: TextStyle(
                fontSize: AppTypography.bodySmall,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        _buildUpcomingBookingCard(
          name: 'Sophie Laurent',
          service: 'Corporate Video',
          date: '2025-12-22',
          time: '09:00 - 12:00',
          price: '800',
          status: 'Pending',
        ),
        _buildUpcomingBookingCard(
          name: 'Pierre Durand',
          service: 'Drone Shoot',
          date: '2025-12-25',
          time: '15:00 - 18:00',
          price: '600',
          status: 'Confirmed',
        ),
        _buildUpcomingBookingCard(
          name: 'Emma Wilson',
          service: 'Wedding Photography',
          date: '2025-12-28',
          time: '10:00 - 20:00',
          price: '2500',
          status: 'Confirmed',
        ),
      ],
    );
  }

  Widget _buildPendingTab() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Pending Approval",
              style: TextStyle(
                fontSize: AppTypography.h1,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '2 requests',
              style: TextStyle(
                fontSize: AppTypography.bodySmall,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        _buildPendingBookingCard(
          name: 'Robert Chen',
          service: 'Product Photography',
          requestedAgo: 'Requested 5 hours ago',
          date: '2025-12-26',
          time: '10:00 - 14:00',
          location: 'Client Office, Manhattan',
          price: '500',
          imageUrl: 'assets/images/img3.png',
        ),
        _buildPendingBookingCard(
          name: 'Lisa Anderson',
          service: 'Event Coverage',
          requestedAgo: 'Requested 1 day ago',
          date: '2025-12-30',
          time: '18:00 - 22:00',
          location: 'Convention Center, Brooklyn',
          price: '500',
          imageUrl: 'assets/images/img4.png',
        ),
      ],
    );
  }

  Widget _buildTodayBookingCard({
    required String name,
    required String service,
    required String time,
    required String location,
    required String price,
    required String imageUrl,
    required String status,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200] ?? Colors.grey),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                CustomNetworkImage(
                  imageUrl: imageUrl,
                  width: 50.r,
                  height: 50.r,
                  shape: BoxShape.circle,
                  fit: BoxFit.cover,
                ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: AppTypography.bodyLarge,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: AppTypography.bodySmall,
                              color: const Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      service,
                      style: TextStyle(
                        fontSize: AppTypography.bodyMedium,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14.sp, color: Colors.grey[600]),
                        SizedBox(width: 6.w),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: AppTypography.bodySmall,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.grey[600]),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              fontSize: AppTypography.bodySmall,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$$price',
                style: TextStyle(
                  fontSize: AppTypography.h2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: _buildButton(
                        text: 'Contact',
                        onTap: () {},
                        isPrimary: false,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Flexible(
                      child: _buildButton(
                        text: 'Details',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingDetailsScreen(),
                            ),
                          );
                        },
                        isPrimary: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingBookingCard({
    required String name,
    required String service,
    required String date,
    required String time,
    required String price,
    required String status,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200] ?? Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: AppTypography.bodyLarge,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      service,
                      style: TextStyle(
                        fontSize: 13.sp.clamp(12, 14),
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: status == 'Confirmed' ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    color: status == 'Confirmed' ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey[600]),
              SizedBox(width: 6.w),
              Text(
                date,
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: 15.w),
              Icon(Icons.access_time, size: 14.sp, color: Colors.grey[600]),
              SizedBox(width: 6.w),
              Text(
                time,
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '\$$price',
                  style: TextStyle(
                    fontSize: AppTypography.h2,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(width: 8.w),
              Flexible(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingDetailsScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: AppTypography.bodyMedium,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.arrow_forward, size: 14.sp, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBookingCard({
    required String name,
    required String service,
    required String requestedAgo,
    required String date,
    required String time,
    required String location,
    required String price,
    required String imageUrl,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200] ?? Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                CustomNetworkImage(
                  imageUrl: imageUrl,
                  width: 50.r,
                  height: 50.r,
                  shape: BoxShape.circle,
                  fit: BoxFit.cover,
                ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: AppTypography.bodyLarge,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Pending',
                            style: TextStyle(
                              fontSize: AppTypography.bodySmall,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      service,
                      style: TextStyle(
                        fontSize: AppTypography.bodyMedium,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      requestedAgo,
                      style: TextStyle(
                        fontSize: AppTypography.bodySmall,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey[600]),
              SizedBox(width: 6.w),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12.sp.clamp(11, 13),
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.access_time, size: 14.sp, color: Colors.grey[600]),
              SizedBox(width: 6.w),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12.sp.clamp(11, 13),
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.grey[600]),
              SizedBox(width: 6.w),
              Text(
                location,
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$$price',
                style: TextStyle(
                  fontSize: AppTypography.h2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: _buildTextButton(
                      text: 'Decline',
                      onTap: () => _showConfirmationDialog(
                        context: context,
                        isAccept: false,
                      ),
                      icon: Icons.close,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Flexible(
                    child: _buildTextButton(
                      text: 'Accept',
                      onTap: () => _showConfirmationDialog(
                        context: context,
                        isAccept: true,
                      ),
                      icon: Icons.check,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingDetailsScreen(),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Full Details',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_forward, size: 14.sp, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required bool isAccept,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAccept ? 'Are you want to Accept this' : 'Are you want to Decline This',
                      style: TextStyle(
                        fontSize: AppTypography.h1,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, size: 24.sp, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Yes Button
                    GestureDetector(
                      onTap: () {
                        // Handle action
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check, size: 18.sp, color: const Color(0xFF2E7D32)),
                            SizedBox(width: 8.w),
                            Text(
                              'Yes',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    // No Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.red.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.close, size: 18.sp, color: Colors.red),
                            SizedBox(width: 8.w),
                            Text(
                              'No',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: isPrimary ? null : Border.all(color: Colors.grey[300] ?? Colors.grey),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp.clamp(12, 14),
            color: isPrimary ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton({
    required String text,
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 13.sp.clamp(12, 14),
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 15.h),
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200] ?? Colors.grey),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300] ?? Colors.grey,
            highlightColor: Colors.grey[100] ?? Colors.white,
            child: Row(
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120.w,
                        height: 16.h,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 180.w,
                        height: 12.h,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 100.w,
                        height: 12.h,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
