import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/controller/client/booking_controller.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/data/models/booking_model.dart';
import 'package:photopia/features/client/widgets/auth_profile_image.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  static const String name = '/order_history';
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedFilter = 'All Orders';
  final List<String> _filters = [
    'All Orders',
    'Upcoming',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingController>().getMyBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp.clamp(20, 22),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Consumer<BookingController>(
              builder: (context, controller, child) {
                if (controller.isLoading && controller.bookings.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredBookings = _getFilteredBookings(
                  controller.bookings,
                );

                if (filteredBookings.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => controller.getMyBookings(),
                    color: Colors.black,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: 400.h,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 60.sp,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No orders found',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.getMyBookings(),
                  color: Colors.black,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(20.w),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(filteredBookings[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60.h,
      color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1A1A1A)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Booking> _getFilteredBookings(List<Booking> bookings) {
    if (_selectedFilter == 'All Orders') return bookings;
    return bookings
        .where((b) => b.status?.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  Widget _buildOrderCard(Booking booking) {
    String formattedDate = booking.bookingDate ?? '';
    if (formattedDate.contains('T')) {
      formattedDate = formattedDate.split('T')[0];
    }

    String coverUrl =
        booking.serviceId?.coverMedia ??
        booking.serviceId?.cover_media ??
        booking.serviceId?.cover_image ??
        '';
    debugPrint("🖼️ Service Title: ${booking.serviceId?.title}");
    debugPrint("🖼️ Raw Cover URL: $coverUrl");

    if (coverUrl.isNotEmpty && !coverUrl.startsWith('http')) {
      if (coverUrl.startsWith('/')) {
        coverUrl = '${Urls.baseUrl}$coverUrl';
      } else {
        coverUrl = '${Urls.baseUrl}/$coverUrl';
      }
    }
    debugPrint("🖼️ Final Cover URL: $coverUrl");

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.r),
                child: coverUrl.isNotEmpty
                    ? Image.network(
                        coverUrl,
                        width: 80.w,
                        height: 80.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80.w,
                          height: 80.w,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 80.w,
                        height: 80.w,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            booking.serviceId?.title ?? 'Service Title',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(booking.status ?? 'PENDING'),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      booking.package?.name ?? 'Standard Package',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Builder(
                          builder: (context) {
                            String? profileUrl = booking.providerId?.profile;
                            if (profileUrl != null &&
                                !profileUrl.startsWith('http')) {
                              profileUrl = '${Urls.baseUrl}$profileUrl';
                            }
                            debugPrint(
                              "👤 Provider Name: ${booking.providerId?.name}",
                            );
                            debugPrint("👤 Final Profile URL: $profileUrl");
                            return AuthProfileImage(
                              imageUrl: profileUrl,
                              size: 24.w,
                            );
                          },
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          booking.providerId?.name ?? 'Provider Name',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
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
          const Divider(),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(width: 15.w),
                  Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
                  SizedBox(width: 6.w),
                  Text(
                    booking.startTime ?? '00:00',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
              Text(
                '${booking.currency ?? booking.pricingDetails?.currency ?? '€'}${booking.totalPrice?.toStringAsFixed(0) ?? '0'}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.grey),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  booking.serviceId?.location?.address ?? 'Location not set',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'upcoming':
      case 'pending':
        color = Colors.blue;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
