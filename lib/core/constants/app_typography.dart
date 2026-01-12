import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Central typography constants for the Photopia application.
/// Uses [flutter_screenutil] to ensure responsiveness across all devices.
class AppTypography {
  // --- Headings ---
  
  /// App bar titles, Main headers (e.g., "Photopia", "Select a Package")
  static double get h1 => 18.sp.clamp(18, 22);
  
  /// Section titles, Step titles (e.g., "Step 1 of 4", "Review Booking")
  static double get h2 => 16.sp.clamp(16, 20);

  // --- Body Text & Labels ---
  
  /// Primary labels, Highlighted values (e.g., "Available Dates", Service Title)
  static double get bodyLarge => 14.sp.clamp(14, 16);
  
  /// General body text, Descriptions, Tab labels
  static double get bodyMedium => 13.sp.clamp(13, 15);
  
  /// Captions, Time stamps, Tags, Unimportant info
  static double get bodySmall => 11.sp.clamp(11, 13);
}
