import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllTap;

  const SectionHeader({super.key, required this.title, this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (onSeeAllTap != null)
            GestureDetector(
              onTap: onSeeAllTap,
              child: Row(
                children: [
                  Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14.sp,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
