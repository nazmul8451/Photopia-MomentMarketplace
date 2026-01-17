import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/core/routes/app_routes.dart';

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
                  Text(
                    'Photopia',
                    style: TextStyle(
                      fontSize: 24.sp.clamp(24, 28),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Stack(
                    children: [
                      Icon(Icons.notifications_outlined, size: 28.sp),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
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
                    fontSize: 14.sp.clamp(14, 16),
                    fontWeight: FontWeight.w600,
                  ),
                  dividerColor: Colors.transparent,
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
                  _buildTodayTab(),
                  _buildUpcomingTab(),
                  _buildPendingTab(),
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
                fontSize: 18.sp.clamp(18, 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '2 bookings',
              style: TextStyle(
                fontSize: 12.sp.clamp(11, 13),
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
          imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200',
          status: 'Confirmed',
        ),
        _buildTodayBookingCard(
          name: 'Jean Martin',
          service: 'Event Photography',
          time: '14:00 - 17:00',
          location: 'Grand Ballroom, Manhattan',
          price: '450',
          imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200',
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
                fontSize: 18.sp.clamp(18, 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '3 bookings',
              style: TextStyle(
                fontSize: 12.sp.clamp(11, 13),
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
                fontSize: 18.sp.clamp(18, 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '2 requests',
              style: TextStyle(
                fontSize: 12.sp.clamp(11, 13),
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
          imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200',
        ),
        _buildPendingBookingCard(
          name: 'Lisa Anderson',
          service: 'Event Coverage',
          requestedAgo: 'Requested 1 day ago',
          date: '2025-12-30',
          time: '18:00 - 22:00',
          location: 'Convention Center, Brooklyn',
          price: '500',
          imageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200',
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
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundImage: NetworkImage(imageUrl),
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
                              fontSize: 15.sp.clamp(14, 16),
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
                              fontSize: 10.sp.clamp(9, 11),
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
                        fontSize: 13.sp.clamp(12, 14),
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
                            fontSize: 12.sp.clamp(11, 13),
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
                              fontSize: 12.sp.clamp(11, 13),
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
                  fontSize: 16.sp.clamp(16, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildButton(
                    text: 'Contact',
                    onTap: () {},
                    isPrimary: false,
                  ),
                  SizedBox(width: 10.w),
                  _buildButton(
                    text: 'Details',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.booking_details);
                    },
                    isPrimary: true,
                  ),
                ],
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
        border: Border.all(color: Colors.grey[200]!),
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
                        fontSize: 15.sp.clamp(14, 16),
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
                    fontSize: 10.sp.clamp(9, 11),
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
                  fontSize: 12.sp.clamp(11, 13),
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: 15.w),
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
                    fontSize: 16.sp.clamp(16, 18),
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.booking_details);
                },
                child: Row(
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12.sp.clamp(11, 13),
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.arrow_forward, size: 14.sp, color: Colors.grey[600]),
                  ],
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
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundImage: NetworkImage(imageUrl),
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
                              fontSize: 15.sp.clamp(14, 16),
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
                              fontSize: 10.sp.clamp(9, 11),
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
                        fontSize: 13.sp.clamp(12, 14),
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      requestedAgo,
                      style: TextStyle(
                        fontSize: 11.sp.clamp(10, 12),
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
                  fontSize: 12.sp.clamp(11, 13),
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
                  fontSize: 16.sp.clamp(16, 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildTextButton(
                    text: 'Decline',
                    onTap: () {},
                    icon: Icons.close,
                    color: Colors.red,
                  ),
                  SizedBox(width: 15.w),
                  _buildTextButton(
                    text: 'Accept',
                    onTap: () {},
                    icon: Icons.check,
                    color: Colors.black,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.booking_details);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Full Details',
                    style: TextStyle(
                      fontSize: 12.sp.clamp(11, 13),
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.arrow_forward, size: 14.sp, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
        ],
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
          border: isPrimary ? null : Border.all(color: Colors.grey[300]!),
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
}
