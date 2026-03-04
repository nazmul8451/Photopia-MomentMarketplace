import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/controller/client/user_profile_controller.dart';
import 'package:photopia/features/client/notification_screen.dart';
import 'package:provider/provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/app_name.png',
                height: 24.h,
                fit: BoxFit.contain,
              ),
              Consumer<UserProfileController>(
                builder: (context, controller, _) {
                  final String location =
                      controller.userProfile?.location ?? 'Set Location';
                  return Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14.sp.clamp(14, 16),
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 12.sp.clamp(12, 14),
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
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
    );
  }
}
