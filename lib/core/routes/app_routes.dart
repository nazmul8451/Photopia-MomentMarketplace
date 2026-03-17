import 'package:flutter/material.dart';
import 'package:photopia/features/client/authentication/otp_verification_screen.dart';
import 'package:photopia/features/client/authentication/sign_up_screen.dart';
import 'package:photopia/features/client/authentication/forgot_password_screen.dart';
import 'package:photopia/features/client/authentication/new_password_screen.dart';
import 'package:photopia/features/client/authentication/log_in_screen.dart';
import 'package:photopia/features/client/BottomNavigation.dart';
import 'package:photopia/features/client/user_profile_screen.dart';
import 'package:photopia/features/client/home_page.dart';
import 'package:photopia/features/client/favorites_screen.dart';
import 'package:photopia/features/client/search_screen.dart';
import 'package:photopia/features/client/notification_screen.dart';
import 'package:photopia/features/client/edit_profile_screen.dart';
import 'package:photopia/features/client/view_profile_screen.dart';
import 'package:photopia/features/common/mode_transition_screen.dart';
import 'package:photopia/features/onboarding/onboarding_screen.dart';
import 'package:photopia/features/onboarding/get_started.dart';
import 'package:photopia/features/onboarding/role_selection_screen.dart';
import 'package:photopia/features/provider/screen/BottomNavigationBar/bottom_navigation_screen.dart';

class AppRoutes {
  static const String sign_up = SignUpScreen.name;
  static const String forgot_password = ForgotPasswordScreen.name;
  static const String otp_verification = OtpVerificationScreen.name;
  static const String new_password = NewPasswordScreen.name;
  static const String log_in = LogInScreen.name;
  static const String bottom_navigation = BottomNavigationScreen.name;
  static const String user_profile = UserProfileScreen.name;
  static const String edit_profile = EditProfileScreen.name;
  static const String view_profile = ViewProfileScreen.name;
  static const String home = "/home";
  static const String search = SearchScreen.name;
  static const String favorites = FavoritesScreen.name;
  static const String notifications = NotificationScreen.name;
  static const String mode_transition = "/mode-transition";
  static const String onboarding = OnboardingScreen.name;
  static const String get_started = GetStartedScreen.name;
  static const String role_selection = RoleSelectionScreen.name;
  static const String provider_bottom_navigation =
      ProviderBottomNavigationScreen.name;
  static const String splash = "/";

  static Map<String, WidgetBuilder> get routes => {    sign_up: (context) => const SignUpScreen(),
    forgot_password: (context) => const ForgotPasswordScreen(),
    otp_verification: (context) {
      final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
      return OtpVerificationScreen(email: email);
    }, 
    new_password: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return NewPasswordScreen(
        email: args?['email'] ?? '',
        token: args?['token'] ?? '',
      );
    },
    bottom_navigation: (context) => const BottomNavigationScreen(),
    user_profile: (context) => const UserProfileScreen(),
    view_profile: (context) => const ViewProfileScreen(),
    edit_profile: (context) => const EditProfileScreen(),
    home: (context) => const MyHomePage(),
    search: (context) => const SearchScreen(),
    favorites: (context) => const FavoritesScreen(),
    notifications: (context) => const NotificationScreen(),
    mode_transition: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      return ModeTransitionScreen(
        targetRole: args?['targetRole'] ?? 'client',
        targetRoute: args?['targetRoute'] ?? bottom_navigation,
      );
    },
    onboarding: (context) => const OnboardingScreen(),
    get_started: (context) => const GetStartedScreen(),
    role_selection: (context) => const RoleSelectionScreen(),
    log_in: (context) => const LogInScreen(),
    provider_bottom_navigation: (context) =>
        const ProviderBottomNavigationScreen(),
  };
}
