import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingDetailsScreen extends StatelessWidget {
  static const String name = "/booking-details";

  const BookingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Booking Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp.clamp(18, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClientInfo(),
            SizedBox(height: 20.h),
            _buildServiceDetails(),
            SizedBox(height: 20.h),
            _buildSpecialNotes(),
            SizedBox(height: 30.h),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfo() {
    return Container(
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
              Text(
                'Client Information',
                style: TextStyle(
                  fontSize: 16.sp.clamp(14, 18),
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Confirmed',
                  style: TextStyle(
                    fontSize: 10.sp.clamp(9, 11),
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              CircleAvatar(
                radius: 35.r,
                backgroundImage: const AssetImage(
                  'assets/images/img6.png',
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Marie Dubois',
                      style: TextStyle(
                        fontSize: 17.sp.clamp(16, 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 14.sp, color: Colors.grey[600]),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'marie.dubois@email.com',
                            style: TextStyle(
                              fontSize: 13.sp.clamp(12, 14),
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 14.sp, color: Colors.grey[600]),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            '+1 (555) 234-5678',
                            style: TextStyle(
                              fontSize: 13.sp.clamp(12, 14),
                              color: Colors.grey[600],
                            ),
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
        ],
      ),
    );
  }

  Widget _buildServiceDetails() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service Details',
            style: TextStyle(
              fontSize: 16.sp.clamp(14, 18),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20.h),
          _buildDetailRow('Service', 'Portrait Photo Session'),
          _buildDetailRow('Date', 'Today'),
          _buildDetailRow('Time', '10:00 - 11:30'),
          _buildDetailRow('Location', 'Central Park, New York'),
          SizedBox(height: 10.h),
          const Divider(),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Price',
                style: TextStyle(
                  fontSize: 14.sp.clamp(13, 15),
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '\$150',
                style: TextStyle(
                  fontSize: 20.sp.clamp(18, 22),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp.clamp(13, 15),
              color: Colors.grey[500],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14.sp.clamp(13, 15),
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialNotes() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Notes',
            style: TextStyle(
              fontSize: 16.sp.clamp(14, 18),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Client prefers natural lighting. Outdoor location.',
            style: TextStyle(
              fontSize: 14.sp.clamp(13, 15),
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Contact Client',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp.clamp(14, 16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  const Icon(Icons.close, color: Colors.red),
                  SizedBox(width: 8.w),
                  Text(
                    'Decline',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.sp.clamp(14, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  const Icon(Icons.check, color: Colors.black),
                  SizedBox(width: 8.w),
                  Text(
                    'Accept',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp.clamp(14, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
