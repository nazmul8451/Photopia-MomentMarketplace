import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/notification_controller.dart';
import 'package:photopia/data/models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  static const String name = "notification";

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationController>().fetchMyNotifications();
    });
  }

  @override
  void dispose() {
    // Mark all as read when leaving the screen
    context.read<NotificationController>().markAllAsRead();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60.h,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Consumer<NotificationController>(
            builder: (context, controller, child) {
              return Column(
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
                  ),
                  Text(
                    '${controller.unreadCount} unread',
                    style: TextStyle(
                      color: const Color(0xFF8E949A),
                      fontSize: 14.sp.clamp(14, 16),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 15.h, right: 8.w),
            child: TextButton(
              onPressed: () {
                context.read<NotificationController>().markAllAsRead();
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
            child: Consumer<NotificationController>(
              builder: (context, controller, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text(
                              'All (${controller.notifications.length})',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.sp.clamp(14, 16),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            height: 2.h,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      body: Consumer<NotificationController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null &&
              controller.notifications.isEmpty) {
            return Center(child: Text(controller.errorMessage!));
          }

          if (controller.notifications.isEmpty) {
            return Center(
              child: Text(
                "No notifications available.",
                style: TextStyle(color: Colors.grey, fontSize: 16.sp),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 16.w),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return GestureDetector(
                onTap: () =>
                    _showNotificationDialog(context, notification, controller),
                child: _buildNotificationCard(notification, index, controller),
              );
            },
          );
        },
      ),
    );
  }

  void _showNotificationDialog(
    BuildContext context,
    NotificationModel notification,
    NotificationController controller,
  ) {
    // Mark as read immediately when clicked
    if (!notification.isRead) {
      controller.markSingleAsRead(notification.id);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20).r,
        ),
        title: Row(
          children: [
            Icon(
              controller.getIconForType(notification.type),
              color: Colors.black,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.content,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            SizedBox(height: 15.h),
            Text(
              controller.formatTime(notification.createdAt),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    int index,
    NotificationController controller,
  ) {
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
              if (!notification.isRead)
                Container(width: 4.w, color: Colors.black),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(15.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8F9FA),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          controller.getIconForType(notification.type),
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
                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 15.sp.clamp(15, 17),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    controller.removeNotification(index);
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
                              notification.content,
                              style: TextStyle(
                                fontSize: 13.sp.clamp(13, 15),
                                color: Colors.grey.shade600,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              controller.formatTime(notification.createdAt),
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
