import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/controller/location_controller.dart';
import 'package:photopia/features/client/notification_screen.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';
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
              Consumer<LocationController>(
                builder: (context, controller, _) {
                  final String location = controller.currentAddress;
                  return Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14.sp.clamp(14, 16),
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4.w),
                      if (controller.isLoading)
                        Container(
                          width: 100.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4).r,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4).r,
                            child: const ShimmerSkeleton(
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        )
                      else
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 12.sp.clamp(12, 14),
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
