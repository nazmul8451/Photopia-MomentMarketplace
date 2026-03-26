import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/provider/provider_orders_controller.dart';

class BookingDetailsScreen extends StatelessWidget {
  static const String name = "/booking-details";
  final Map<String, dynamic> booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final client = booking['clientId'] is Map ? booking['clientId'] : {};
    final service = booking['serviceId'] is Map ? booking['serviceId'] : {};
    final location = booking['eventLocation'] is Map ? booking['eventLocation'] : {};

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
            _buildClientInfo(client),
            SizedBox(height: 20.h),
            _buildServiceDetails(service, location),
            SizedBox(height: 20.h),
            _buildSpecialNotes(location['notes'] ?? 'No special notes provided'),
            SizedBox(height: 30.h),
            _buildActionButtons(context, booking['status'] ?? 'pending'),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfo(Map<String, dynamic> client) {
    final status = booking['status']?.toString() ?? 'pending';
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
                  color: status.toLowerCase() == 'confirmed' ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                    fontSize: 10.sp.clamp(9, 11),
                    color: status.toLowerCase() == 'confirmed' ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
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
                backgroundColor: Colors.grey[200],
                backgroundImage: client['profile'] != null && client['profile'].toString().isNotEmpty
                  ? NetworkImage(client['profile'])
                  : null,
                child: client['profile'] == null || client['profile'].toString().isEmpty
                  ? Icon(Icons.person, size: 35.r, color: Colors.grey)
                  : null,
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client['name'] ?? 'Unknown Client',
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
                            client['email'] ?? 'No email available',
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

  Widget _buildServiceDetails(Map<String, dynamic> service, Map<String, dynamic> location) {
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
          _buildDetailRow('Service', service['title'] ?? 'Generic Service'),
          _buildDetailRow('Date', booking['bookingDate']?.toString().split('T')[0] ?? 'N/A'),
          _buildDetailRow('Time', '${booking['startTime'] ?? 'N/A'} - ${booking['endTime'] ?? ''}'),
          _buildDetailRow('Location', location['address'] ?? 'Location N/A'),
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
                '€${booking['pricingDetails']?['subtotal'] ?? 
                   booking['pricingDetails']?['clientTotal'] ?? 
                   booking['totalAmount'] ?? '0'}',
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

  Widget _buildSpecialNotes(String notes) {
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
            notes.isEmpty ? 'No special notes provided' : notes,
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

  Widget _buildActionButtons(BuildContext context, String status) {
    final isPending = status.toLowerCase() == 'pending';
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
        if (isPending) ...[
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTextActionButton(context, 'Decline', Icons.close, Colors.red, false),
              _buildTextActionButton(context, 'Accept', Icons.check, Colors.black, true),
            ],
          ),
        ],
      ],
    );
  }

  void _showConfirmationDialog({
    required BuildContext context,
    required bool isAccept,
    required String bookingId,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
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
                        isAccept ? 'Are you want to Accept this' : 'Are you want to Decline This',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(dialogContext),
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
                      onTap: () async {
                        final status = isAccept ? 'confirmed' : 'cancelled';
                        final controller = Provider.of<ProviderOrdersController>(context, listen: false);
                        
                        // Close dialog
                        Navigator.pop(dialogContext);
                        
                        final success = await controller.updateOrderStatus(bookingId, status);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success 
                                ? 'Order ${isAccept ? 'accepted' : 'declined'} successfully!' 
                                : 'Failed to update order status'),
                              backgroundColor: success ? Colors.green : Colors.red,
                            ),
                          );
                          if (success) {
                            // Delay slightly to allow user to see the snackbar if needed, 
                            // or just pop back to the list screen
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check, color: const Color(0xFF2E7D32), size: 18.sp),
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
                    SizedBox(width: 15.w),
                    // No Button
                    GestureDetector(
                      onTap: () => Navigator.pop(dialogContext),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 42.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.close, color: const Color(0xFFC62828), size: 18.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'No',
                              style: TextStyle(
                                color: const Color(0xFFC62828),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
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

  Widget _buildTextActionButton(BuildContext context, String text, IconData icon, Color color, bool isAccept) {
    return GestureDetector(
      onTap: () {
        final bookingId = booking['_id'] ?? '';
        if (bookingId.isEmpty) return;
        _showConfirmationDialog(
          context: context,
          isAccept: isAccept,
          bookingId: bookingId,
        );
      },
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 16.sp.clamp(14, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
