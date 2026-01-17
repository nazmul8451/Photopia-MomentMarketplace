import 'package:flutter/material.dart';
import 'package:photopia/features/client/home_page.dart';
import 'package:photopia/features/client/category_details_screen.dart';
import 'package:photopia/features/client/search_filter_screen.dart';
import 'package:photopia/features/client/notification_screen.dart';
import 'package:photopia/features/client/BottomNavigation.dart';
import 'package:photopia/features/client/authentication/log_in_screen.dart';
import 'package:photopia/features/client/authentication/sign_up_screen.dart';
import 'package:photopia/features/client/authentication/forgot_password_screen.dart';
import 'package:photopia/features/client/authentication/otp_verification_screen.dart';
import 'package:photopia/features/client/authentication/new_password_screen.dart';
import 'package:photopia/features/provider/screen/BottomNavigationBar/bottom_navigation_screen.dart';
import 'package:photopia/features/provider/screen/booking_details_screen.dart';

class AppRoutes {
  static const String home_page = MyHomePage.name;
  static const String category_details = CategoryDetailsScreen.name;
  static const String search_filter = SearchFilterScreen.name;
  static const String notification = NotificationScreen.name;
  static const String bottom_navigation = BottomNavigationScreen.name;
  static const String log_in = LogInScreen.name;
  static const String sign_up = SignUpScreen.name;
  static const String forgot_password = ForgotPasswordScreen.name;
  static const String otp_verification = OtpVerificationScreen.name;
  static const String new_password = NewPasswordScreen.name;
  static const String provider_bottom_navigation = ProviderBottomNavigationScreen.name;
  static const String booking_details = BookingDetailsScreen.name;

  static final routes = {
    home_page: (context) => const MyHomePage(),
    category_details: (context) => const CategoryDetailsScreen(),
    search_filter: (context) => const SearchFilterScreen(),
    notification: (context) => const NotificationScreen(),
    bottom_navigation: (context) => const BottomNavigationScreen(),
    log_in: (context) => const LogInScreen(),
    sign_up: (context) => const SignUpScreen(),
    forgot_password: (context) => const ForgotPasswordScreen(),
    otp_verification: (context) {
      final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
      return OtpVerificationScreen(email: email);
    },
    new_password: (context) => const NewPasswordScreen(),
    provider_bottom_navigation: (context) => const ProviderBottomNavigationScreen(),
    booking_details: (context) => const BookingDetailsScreen(),
  };
}