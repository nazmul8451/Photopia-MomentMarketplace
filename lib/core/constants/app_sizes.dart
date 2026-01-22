import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Central size constants for the Photopia application.
/// Uses [flutter_screenutil] to ensure responsiveness across all devices.
class AppSizes {
  /// Standard height for buttons and text fields
  /// Reduced from 50.h as per user request
  static double get fieldHeight => 45.h.clamp(45, 50);
  
  /// Standard border radius for fields and buttons
  static double get borderRadius => 12.r;
  
  /// Standard spacing between elements
  static double get spacingSmall => 8.h.clamp(8, 12);
  static double get spacingMedium => 16.h.clamp(16, 20);
  static double get spacingLarge => 24.h.clamp(24, 32);
}
