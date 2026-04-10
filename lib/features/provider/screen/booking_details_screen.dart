import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/provider/provider_orders_controller.dart';
import 'package:photopia/core/widgets/custom_snacbar.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/core/widgets/custom_network_image.dart';
import 'package:photopia/data/models/conversation_model.dart';
import 'package:photopia/data/models/chat_message_model.dart';
import 'package:photopia/features/client/chat_screen.dart';

class BookingDetailsScreen extends StatelessWidget {
  static const String name = "/booking-details";
  final Map<String, dynamic> booking;

  const BookingDetailsScreen({super.key, required this.booking});

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
      body: FutureBuilder(
        future: NetworkCaller.getRequest(url: Urls.getSingleBooking(booking['_id'] ?? booking['id'] ?? '')),
        builder: (context, snapshot) {
          Map<String, dynamic> currentBooking = booking;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final response = snapshot.data!;
            if (response.isSuccess && response.body != null) {
              final rawData = response.body!['data'];
              currentBooking = (rawData is Map && rawData.containsKey('booking')) 
                  ? rawData['booking'] 
                  : rawData ?? booking;
            }
          }

          final client = currentBooking['clientId'] is Map ? currentBooking['clientId'] : <String, dynamic>{};
          final service = currentBooking['serviceId'] is Map ? currentBooking['serviceId'] : <String, dynamic>{};
          final location = currentBooking['eventLocation'] is Map ? currentBooking['eventLocation'] : <String, dynamic>{};

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClientInfo(client, currentBooking),
                SizedBox(height: 20.h),
                _buildServiceDetails(service, location, currentBooking),
                SizedBox(height: 20.h),
                _buildSpecialNotes(location['notes']?.toString() ?? 'No special notes provided'),
                SizedBox(height: 30.h),
                _buildActionButtons(context, currentBooking['status']?.toString() ?? 'pending', currentBooking),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClientInfo(Map<String, dynamic> client, Map<String, dynamic> currentBooking) {
    final status = currentBooking['status']?.toString() ?? 'pending';
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Client Information',
                    style: TextStyle(
                      fontSize: 16.sp.clamp(14, 18),
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  if (currentBooking['depositPercentage'] != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 14.sp, color: Colors.green),
                        SizedBox(width: 4.w),
                        Text(
                          'Deposit Paid: ${((currentBooking['depositPercentage'] ?? 1.0) * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
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
              CustomNetworkImage(
                imageUrl: client['profile'] ?? client['profileImage'] ?? client['image'] ?? client['avatar'] ?? '',
                width: 70.r,
                height: 70.r,
                shape: BoxShape.circle,
                fit: BoxFit.cover,
                placeholder: Icon(Icons.person, size: 35.r, color: Colors.grey),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client['name'] ?? currentBooking['clientName'] ?? 'Unknown Client',
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
                            client['email'] ?? currentBooking['clientEmail'] ?? 'No email available',
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

  Widget _buildServiceDetails(Map<String, dynamic> service, Map<String, dynamic> location, Map<String, dynamic> currentBooking) {
    // 1. Move logic to the START of the function
    final String displayPrice = () {
      String price = '0';
      final pricingDetails = currentBooking['pricingDetails'];
      final String? packageName = currentBooking['packageName'];
      
      if (pricingDetails != null && pricingDetails['baseRate'] != null && pricingDetails['baseRate'] != 0) {
        price = pricingDetails['baseRate'].toString();
      } else if (packageName != null && service['pricingModel'] != null && service['pricingModel']['packages'] != null) {
        final List packages = service['pricingModel']['packages'];
        final package = packages.firstWhere((p) => p['name'] == packageName, orElse: () => null);
        if (package != null) {
          price = package['price']?.toString() ?? service['price']?.toString() ?? '0';
        }
      }
      
      if (price == '0' || price == '0.0') {
        if (pricingDetails != null && pricingDetails['subtotal'] != null && pricingDetails['subtotal'] != 0) {
          price = pricingDetails['subtotal'].toString();
        } else if (currentBooking['totalAmount'] != null && currentBooking['totalAmount'] != 0) {
          price = currentBooking['totalAmount'].toString();
        } else {
          price = service['price']?.toString() ?? '0';
        }
      }
      return price;
    }();

    double dPrice = double.tryParse(displayPrice) ?? 0;
    double dDepositPercent = double.tryParse(currentBooking['depositPercentage']?.toString() ?? '1.0') ?? 1.0;
    double displayPaid = dPrice * dDepositPercent;
    double displayRemaining = dPrice - displayPaid;

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
          _buildDetailRow('Date', currentBooking['bookingDate']?.toString().split('T')[0] ?? 'N/A'),
          _buildDetailRow('Time', '${currentBooking['startTime'] ?? 'N/A'} - ${currentBooking['endTime'] ?? ''}'),
          _buildDetailRow('Location', location['address'] ?? 'Location N/A'),
          SizedBox(height: 10.h),
          const Divider(),
          SizedBox(height: 10.h),
          SizedBox(height: 10.h),
          const Divider(),
          SizedBox(height: 10.h),
          
          // Total Price Row
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
                '€$displayPrice',
                style: TextStyle(
                  fontSize: 18.sp.clamp(16, 20),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          
          // Payment Breakdown (Deposit & Balance)
          if (currentBooking['depositPercentage'] != null && currentBooking['depositPercentage'] < 1.0) ...[
            SizedBox(height: 12.h),
            _buildPaymentDetailRow(
              'Paid (Deposit ${((dDepositPercent) * 100).toInt()}%)', 
              '€${displayPaid.toStringAsFixed(2)}',
              color: const Color(0xFF4CAF50),
            ),
            SizedBox(height: 8.h),
            _buildPaymentDetailRow(
              'Remaining Balance', 
              '€${displayRemaining.toStringAsFixed(2)}',
              color: Colors.redAccent,
              isBold: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentDetailRow(String label, String value, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp.clamp(12, 14),
            color: Colors.grey[600],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp.clamp(13, 15),
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.black,
          ),
        ),
      ],
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

  Widget _buildActionButtons(BuildContext context, String status, Map<String, dynamic> currentBooking) {
    final clientMap = currentBooking['clientId'] is Map ? currentBooking['clientId'] : <String, dynamic>{};
    
    // Support situations where clientId is populated or just a string reference
    String clientId = '';
    if (clientMap.isNotEmpty) {
      clientId = clientMap['_id']?.toString() ?? clientMap['id']?.toString() ?? '';
    } else if (currentBooking['clientId'] is String) {
      clientId = currentBooking['clientId'].toString();
    }
    // Also fallback to root fields if backend gives them there
    clientId = clientId.isEmpty ? (currentBooking['client'] ?? '') : clientId;

    final clientName = clientMap['name']?.toString() ?? currentBooking['clientName']?.toString() ?? 'Client';
    final clientAvatar = clientMap['profile'] ?? clientMap['profileImage'] ?? clientMap['image'] ?? clientMap['avatar'] ?? '';

    final isPending = status.toLowerCase() == 'pending';
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () {
              if (clientId.isEmpty) {
                CustomSnackBar.show(
                  context: context,
                  message: 'Client information not available',
                  isError: true,
                );
                return;
              }
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
            },
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
              _buildTextActionButton(context, 'Decline', Icons.close, Colors.red, false, currentBooking),
              _buildTextActionButton(context, 'Accept', Icons.check, Colors.black, true, currentBooking),
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
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final status = isAccept ? 'confirmed' : 'cancelled';
                          final controller = Provider.of<ProviderOrdersController>(context, listen: false);
                          
                          // Close dialog
                          Navigator.pop(dialogContext);
                          
                          final success = await controller.updateOrderStatus(bookingId, status);
                          
                          if (context.mounted) {
                            CustomSnackBar.show(
                              context: context,
                              message: success 
                                ? 'Order ${isAccept ? 'accepted' : 'declined'} successfully!' 
                                : 'Failed to update order status',
                              isError: !success,
                            );
                            if (success) {
                              Navigator.of(context).pop();
                            }
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
                    ),
                    SizedBox(width: 15.w),
                    // No Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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

  Widget _buildTextActionButton(BuildContext context, String text, IconData icon, Color color, bool isAccept, Map<String, dynamic> currentBooking) {
    return GestureDetector(
      onTap: () {
        final bookingId = currentBooking['_id'] ?? currentBooking['id'] ?? '';
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
