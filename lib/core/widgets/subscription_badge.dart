import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionBadge extends StatelessWidget {
  final bool isSubscribed;
  final double? fontSize;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;

  const SubscriptionBadge({
    super.key,
    required this.isSubscribed,
    this.fontSize,
    this.iconSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (isSubscribed) {
      return Container(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stars,
              color: Colors.amber,
              size: iconSize ?? 12.sp,
            ),
            SizedBox(width: 4.w),
            Text(
              'Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize ?? 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE9ECEF),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          'Free',
          style: TextStyle(
            color: const Color(0xFF495057),
            fontSize: fontSize ?? 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }
}
