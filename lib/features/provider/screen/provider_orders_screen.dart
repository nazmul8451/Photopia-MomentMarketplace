import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/provider/screen/provider_notification_screen.dart';
import 'package:photopia/features/provider/screen/booking_details_screen.dart';
import 'package:photopia/core/widgets/custom_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/provider/provider_orders_controller.dart';
import 'package:photopia/core/widgets/custom_snacbar.dart';
import 'package:photopia/data/models/conversation_model.dart';
import 'package:photopia/data/models/chat_message_model.dart';
import 'package:photopia/features/client/chat_screen.dart';

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
    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCurrentTab();
    });
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      _fetchCurrentTab();
    }
  }

  void _fetchCurrentTab() {
    final controller = context.read<ProviderOrdersController>();
    if (_tabController.index == 0) {
      controller.getMyOrders(filterType: 'today');
    } else if (_tabController.index == 1) {
      controller.getMyOrders(filterType: 'upcoming');
    } else if (_tabController.index == 2) {
      controller.getMyOrders(status: 'pending');
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
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
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: TabBar(
                  controller: _tabController,
                  padding: EdgeInsets.all(4.w),
                  indicator: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF455A64),
                  labelStyle: TextStyle(
                    fontSize: 12.sp.clamp(11, 13),
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 12.sp.clamp(11, 13),
                    fontWeight: FontWeight.w500,
                  ),
                  dividerColor: Colors.transparent,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  tabs: [
                    Tab(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Today'),
                        ),
                      ),
                    ),
                    Tab(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Upcoming'),
                        ),
                      ),
                    ),
                    Tab(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Pending'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Bar View
            Expanded(
              child: Consumer<ProviderOrdersController>(
                builder: (context, controller, child) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      controller.inProgress ? _buildShimmerLoading() : _buildTodayTab(controller),
                      controller.inProgress ? _buildShimmerLoading() : _buildUpcomingTab(controller),
                      controller.inProgress ? _buildShimmerLoading() : _buildPendingTab(controller),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayTab(ProviderOrdersController controller) {
    final todayOrders = controller.orders;
    
    return RefreshIndicator(
      color: Colors.black,
      backgroundColor: Colors.white,
      onRefresh: () => controller.getMyOrders(filterType: 'today'),
      child: ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: todayOrders.isEmpty ? 1 : todayOrders.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
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
                    '${todayOrders.length} bookings',
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              if (todayOrders.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50.h),
                    child: Text('No bookings right now'),
                  ),
                ),
            ],
          );
        }
        
        final order = todayOrders[index - 1];
        final client = order['clientId'] is Map ? order['clientId'] : {};
        final service = order['serviceId'] is Map ? order['serviceId'] : {};
        final location = order['eventLocation'] is Map ? order['eventLocation'] : {};

        // Updated Price extraction logic for Today tab
        String price = '0';
        final pricingDetails = order['pricingDetails'];
        final String? packageName = order['packageName'];
        
        // Priority 1: Base Rate (What the user saw during booking)
        if (pricingDetails != null && pricingDetails['baseRate'] != null && pricingDetails['baseRate'] != 0) {
          price = pricingDetails['baseRate'].toString();
        } 
        // Priority 2: Package Matching
        else if (packageName != null && service['pricingModel'] != null && service['pricingModel']['packages'] != null) {
          final List packages = service['pricingModel']['packages'];
          final package = packages.firstWhere((p) => p['name'] == packageName, orElse: () => null);
          if (package != null) {
            price = package['price']?.toString() ?? service['price']?.toString() ?? '0';
          }
        }
        
        // Fallbacks
        if (price == '0' || price == '0.0') {
          if (pricingDetails != null && pricingDetails['subtotal'] != null && pricingDetails['subtotal'] != 0) {
            price = pricingDetails['subtotal'].toString();
          } else if (order['totalAmount'] != null && order['totalAmount'] != 0) {
            price = order['totalAmount'].toString();
          } else {
            price = service['price']?.toString() ?? '0';
          }
        }

        return _buildTodayBookingCard(
          name: client['name'] ?? 'Unknown Client',
          service: service['title'] ?? 'Unknown Service',
          time: order['startTime'] ?? 'N/A',
          location: location['address'] ?? 'Location N/A',
          price: price,
          imageUrl: client['profile'] ?? client['profileImage'] ?? client['image'] ?? client['avatar'] ?? '',
          status: order['status'] ?? 'pending',
          booking: order,
        );
      },
    ),
  );
}

  Widget _buildUpcomingTab(ProviderOrdersController controller) {
    final upcomingOrders = controller.orders;
    
    return RefreshIndicator(
      color: Colors.black,
      backgroundColor: Colors.white,
      onRefresh: () => controller.getMyOrders(filterType: 'upcoming'),
      child: ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: upcomingOrders.isEmpty ? 1 : upcomingOrders.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
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
                    '${upcomingOrders.length} bookings',
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              if (upcomingOrders.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50.h),
                    child: Text('No upcoming bookings'),
                  ),
                ),
            ],
          );
        }
        
        final order = upcomingOrders[index - 1];
        final client = order['clientId'] is Map ? order['clientId'] : {};
        final service = order['serviceId'] is Map ? order['serviceId'] : {};

        // Updated Price extraction logic for Upcoming tab
        String price = '0';
        final pricingDetails = order['pricingDetails'];
        final String? packageName = order['packageName'];
        
        // Priority 1: Base Rate (What the user saw during booking)
        if (pricingDetails != null && pricingDetails['baseRate'] != null && pricingDetails['baseRate'] != 0) {
          price = pricingDetails['baseRate'].toString();
        } 
        // Priority 2: Package Matching
        else if (packageName != null && service['pricingModel'] != null && service['pricingModel']['packages'] != null) {
          final List packages = service['pricingModel']['packages'];
          final package = packages.firstWhere((p) => p['name'] == packageName, orElse: () => null);
          if (package != null) {
            price = package['price']?.toString() ?? service['price']?.toString() ?? '0';
          }
        }
        
        // Fallbacks
        if (price == '0' || price == '0.0') {
          if (pricingDetails != null && pricingDetails['subtotal'] != null && pricingDetails['subtotal'] != 0) {
            price = pricingDetails['subtotal'].toString();
          } else if (order['totalAmount'] != null && order['totalAmount'] != 0) {
            price = order['totalAmount'].toString();
          } else {
            price = service['price']?.toString() ?? '0';
          }
        }

        return _buildUpcomingBookingCard(
          name: client['name'] ?? 'Unknown Client',
          service: service['title'] ?? 'Unknown Service',
          date: order['bookingDate']?.toString().split('T')[0] ?? 'N/A',
          time: order['startTime'] ?? 'N/A',
          price: price,
          status: order['status'] ?? 'confirmed',
          booking: order,
        );
      },
    ),
  );
}

  Widget _buildPendingTab(ProviderOrdersController controller) {
    final pendingOrders = controller.orders;
    
    return RefreshIndicator(
      color: Colors.black,
      backgroundColor: Colors.white,
      onRefresh: () => controller.getMyOrders(status: 'pending'),
      child: ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: pendingOrders.isEmpty ? 1 : pendingOrders.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
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
                    '${pendingOrders.length} requests',
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              if (pendingOrders.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50.h),
                    child: Text('No pending requests'),
                  ),
                ),
            ],
          );
        }
        
        final order = pendingOrders[index - 1];
        final client = order['clientId'] is Map ? order['clientId'] : {};
        final service = order['serviceId'] is Map ? order['serviceId'] : {};
        final location = order['eventLocation'] is Map ? order['eventLocation'] : {};

        // Updated Price extraction logic for Pending tab
        String price = '0';
        final pricingDetails = order['pricingDetails'];
        final String? packageName = order['packageName'];
        
        // Priority 1: Base Rate (What the user saw during booking)
        if (pricingDetails != null && pricingDetails['baseRate'] != null && pricingDetails['baseRate'] != 0) {
          price = pricingDetails['baseRate'].toString();
        } 
        // Priority 2: Package Matching
        else if (packageName != null && service['pricingModel'] != null && service['pricingModel']['packages'] != null) {
          final List packages = service['pricingModel']['packages'];
          final package = packages.firstWhere((p) => p['name'] == packageName, orElse: () => null);
          if (package != null) {
            price = package['price']?.toString() ?? service['price']?.toString() ?? '0';
          }
        }
        
        // Fallbacks
        if (price == '0' || price == '0.0') {
          if (pricingDetails != null && pricingDetails['subtotal'] != null && pricingDetails['subtotal'] != 0) {
            price = pricingDetails['subtotal'].toString();
          } else if (order['totalAmount'] != null && order['totalAmount'] != 0) {
            price = order['totalAmount'].toString();
          } else {
            price = service['price']?.toString() ?? '0';
          }
        }

        return _buildPendingBookingCard(
          name: client['name'] ?? 'Unknown Client',
          service: service['title'] ?? 'Unknown Service',
          requestedAgo: 'Requested recently',
          date: order['bookingDate']?.toString().split('T')[0] ?? 'N/A',
          time: order['startTime'] ?? 'N/A',
          location: location['address'] ?? 'Location N/A',
          price: price,
          imageUrl: client['profile'] ?? client['profileImage'] ?? client['image'] ?? client['avatar'] ?? '',
          booking: order,
        );
      },
    ),
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
    required Map<String, dynamic> booking,
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
                            color: status.toString().toLowerCase() == 'confirmed' 
                              ? const Color(0xFFE8F5E9) 
                              : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: AppTypography.bodySmall,
                              color: status.toString().toLowerCase() == 'confirmed' 
                                ? const Color(0xFF2E7D32) 
                                : const Color(0xFFE65100),
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
                '€$price',
                style: TextStyle(
                  fontSize: AppTypography.h2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildButton(
                      text: 'Contact',
                      onTap: () => _navigateToChat(context, booking),
                      isPrimary: false,
                    ),
                    SizedBox(width: 10.w),
                    _buildButton(
                      text: 'Details',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingDetailsScreen(booking: booking),
                          ),
                        );
                      },
                      isPrimary: true,
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
    required Map<String, dynamic> booking,
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
                  color: status.toString().toLowerCase() == 'confirmed' ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    color: status.toString().toLowerCase() == 'confirmed' ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
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
                  '€$price',
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
                          builder: (context) => BookingDetailsScreen(booking: booking),
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
    required Map<String, dynamic> booking,
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
                  '€$price',
                  style: TextStyle(
                    fontSize: AppTypography.h2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _buildButton(
                      text: 'Contact',
                      onTap: () => _navigateToChat(context, booking),
                      isPrimary: false,
                    ),
                    SizedBox(width: 10.w),
                    _buildTextButton(
                      text: 'Decline',
                      onTap: () => _showConfirmationDialog(
                        context: context,
                        isAccept: false,
                        bookingId: booking['_id'] ?? '',
                      ),
                      icon: Icons.close,
                      color: Colors.red,
                    ),
                    SizedBox(width: 15.w),
                    _buildTextButton(
                      text: 'Accept',
                      onTap: () => _showConfirmationDialog(
                        context: context,
                        isAccept: true,
                        bookingId: booking['_id'] ?? '',
                      ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingDetailsScreen(booking: booking),
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

  void _navigateToChat(BuildContext context, Map<String, dynamic> booking) {
    final clientMap = booking['clientId'] is Map ? booking['clientId'] : <String, dynamic>{};
    
    String clientId = '';
    if (clientMap.isNotEmpty) {
      clientId = clientMap['_id']?.toString() ?? clientMap['id']?.toString() ?? '';
    } else if (booking['clientId'] is String) {
      clientId = booking['clientId'].toString();
    }
    clientId = clientId.isEmpty ? (booking['client']?.toString() ?? '') : clientId;

    if (clientId.isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: 'Client information not available',
        isError: true,
      );
      return;
    }

    final clientName = clientMap['name']?.toString() ?? booking['clientName']?.toString() ?? 'Client';
    final clientAvatar = clientMap['profile'] ?? clientMap['profileImage'] ?? clientMap['image'] ?? clientMap['avatar'] ?? '';

    final conversation = Conversation(
      id: '',
      name: clientName,
      lastMessage: '',
      avatarUrl: clientAvatar,
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isOnline: false,
      status: MessageStatus.read,
      isTemporary: true,
      receiverId: clientId,
    );

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(conversation: conversation),
      ),
    );
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required bool isAccept,
    required String bookingId,
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
                    Expanded(
                      child: Text(
                        isAccept ? 'Do you want to accept this?' : 'Do you want to decline this?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
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
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final status = isAccept ? 'confirmed' : 'cancelled';
                          final controller = Provider.of<ProviderOrdersController>(context, listen: false);
                          
                          // Close dialog
                          Navigator.pop(context);
                          
                          final success = await controller.updateOrderStatus(bookingId, status);
                          
                          if (context.mounted) {
                            CustomSnackBar.show(
                              context: context,
                              message: success 
                                ? 'Order ${isAccept ? 'accepted' : 'declined'} successfully!' 
                                : 'Failed to update order status',
                              isError: !success,
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check, color: Color(0xFF2E7D32), size: 18),
                              SizedBox(width: 8.w),
                              Text(
                                'Yes',
                                style: TextStyle(
                                  color: const Color(0xFF2E7D32),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    // No Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close, size: 18.sp, color: Colors.red),
                              SizedBox(width: 8.w),
                              Text(
                                'No',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
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
