import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      duration: const Duration(seconds: 4),
      content: Container(
        margin: EdgeInsets.only(bottom: 12.h, left: 16.w, right: 16.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            20.r,
          ), // Gently rounded rectangle shape
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 65, 64, 64).withOpacity(0.85),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    height: 36.w,
                    width: 36.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isError
                          ? const Color(0xFF3B1E1E) // Dark transparent red
                          : const Color(0xFF1B3B22), // Dark transparent green
                      border: Border.all(
                        color: isError
                            ? const Color(0xFFE53935).withOpacity(0.5)
                            : const Color(0xFF4CAF50).withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      isError ? Icons.close : Icons.check,
                      color: isError
                          ? const Color(0xFFE53935)
                          : const Color(0xFF4CAF50),
                      size: 20.w,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Message
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Action button (Optional)
                  if (actionLabel != null && onAction != null) ...[
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        onAction();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        color: Colors.transparent,
                        child: Text(
                          actionLabel.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],

                  // Close icon
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.7),
                        size: 14.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
