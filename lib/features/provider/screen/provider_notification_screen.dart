import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProviderNotificationScreen extends StatefulWidget {
  const ProviderNotificationScreen({super.key});
  static const String name = "provider-notification";

  @override
  State<ProviderNotificationScreen> createState() => _ProviderNotificationScreenState();
}

class _ProviderNotificationScreenState extends State<ProviderNotificationScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New Booking Request',
      'description': 'You have a new booking request from Sarah Johnson for Dec 22',
      'timeAgo': '1 hour ago',
      'icon': Icons.calendar_today_outlined,
      'isUnread': true,
    },
    {
      'title': 'New Message',
      'description': 'James Miller sent you a message regarding the wedding shoot',
      'timeAgo': '3 hours ago',
      'icon': Icons.chat_bubble_outline,
      'isUnread': true,
    },
    {
      'title': 'Payment Received',
      'description': 'Payment of €800 from Emma Wilson has been credited to your account',
      'timeAgo': '1 day ago',
      'icon': Icons.account_balance_wallet_outlined,
      'isUnread': false,
    },
    {
      'title': 'Review Received',
      'description': "Lucas Brown left you a 5-star review: 'Amazing photographer!'",
      'timeAgo': '2 days ago',
      'icon': Icons.star_border,
      'isUnread': false,
    },
    {
      'title': 'System Update',
      'description': 'We have updated our terms and conditions for providers',
      'timeAgo': '5 days ago',
      'icon': Icons.info_outline,
      'isUnread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60.h,
        leading: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(top: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.sp.clamp(20, 22),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_notifications.where((n) => n['isUnread']).length} unread',
                  style: TextStyle(
                    color: const Color(0xFF8E949A),
                    fontSize: 14.sp.clamp(14, 16),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 15.h, right: 8.w),
            child: TextButton(
              onPressed: () {
                setState(() {
                  for (var n in _notifications) {
                    n['isUnread'] = false;
                  }
                });
              },
              child: Text(
                'Mark all as read',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp.clamp(14, 16),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 5.w),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.h),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IntrinsicWidth(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          'All (${_notifications.length})',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp.clamp(14, 16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        height: 2.h,
                        width: double.infinity,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 16.w),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationCard(notification, index);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15).r,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15).r,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Unread Indicator
              if (notification['isUnread'])
                Container(
                  width: 4.w,
                  color: Colors.black,
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(15.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          notification['icon'],
                          size: 20.sp.clamp(20, 22),
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 15.w),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification['title'],
                                    style: TextStyle(
                                      fontSize: 15.sp.clamp(15, 17),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _notifications.removeAt(index);
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 16.sp.clamp(16, 18),
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              notification['description'],
                              style: TextStyle(
                                fontSize: 13.sp.clamp(13, 15),
                                color: Colors.grey.shade600,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              notification['timeAgo'],
                              style: TextStyle(
                                fontSize: 12.sp.clamp(12, 14),
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
