import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/home_page.dart';
import 'package:photopia/features/client/BottomNavigation.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/favorites_controller.dart';
import 'package:photopia/controller/provider/provider_profile_controller.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/controller/client/sign_up_controller.dart';
import 'package:photopia/controller/client/sign_in_controller.dart';
import 'package:photopia/controller/client/log_out_controller.dart';
import 'package:photopia/controller/client/verify_otp_controller.dart';
import 'package:photopia/controller/client/forgot_pass_controller.dart';
import 'package:photopia/controller/client/reset_password_controller.dart';
import 'package:photopia/controller/client/user_profile_controller.dart';
import 'package:photopia/controller/client/role_switch_controller.dart';
import 'package:photopia/controller/provider/service_controller.dart';
import 'package:photopia/controller/provider/calender_availibility_controller.dart';
import 'package:photopia/controller/provider/my_listing_controller.dart';
import 'package:photopia/controller/client/service_list_controller.dart';
import 'package:photopia/controller/provider/provider_orders_controller.dart';
import 'package:photopia/controller/client/provider_details_controller.dart';
import 'package:photopia/controller/common/bottom_nav_controller.dart';
import 'package:photopia/controller/client/review_controller.dart';
import 'package:photopia/controller/provider/wallet_controller.dart';
import 'package:photopia/controller/client/chat_controller.dart';
import 'package:photopia/controller/client/booking_controller.dart';
import 'package:photopia/controller/provider/statistics_controller.dart';
import 'package:photopia/controller/location_controller.dart';
import 'package:photopia/core/routes/app_routes.dart';
import 'package:photopia/features/onboarding/get_started.dart';
import 'package:photopia/features/provider/screen/BottomNavigationBar/bottom_navigation_screen.dart';

class Photopia extends StatelessWidget {
  const Photopia({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => FavoritesController()),
            ChangeNotifierProvider(create: (_) => ProviderProfileController()),
            ChangeNotifierProvider(create: (_) => AuthController()),
            ChangeNotifierProvider(create: (_) => SignUpController()),
            ChangeNotifierProvider(create: (_) => SignInController()),
            ChangeNotifierProvider(create: (_) => LogOutController()),
            ChangeNotifierProvider(create: (_) => VerifyOtpController()),
            ChangeNotifierProvider(create: (_) => ForgotPassController()),
            ChangeNotifierProvider(create: (_) => ResetPasswordController()),
            ChangeNotifierProvider(create: (_) => UserProfileController()),
            ChangeNotifierProvider(create: (_) => RoleSwitchController()),
            ChangeNotifierProvider(create: (_) => MyListingController()),
            ChangeNotifierProvider(create: (_) => ServiceController()),
            ChangeNotifierProvider(create: (_) => ServiceListController()),
            ChangeNotifierProvider(create: (_) => BottomNavController()),
            ChangeNotifierProvider(
              create: (_) => CalenderAvailibilityController(),
            ),
            ChangeNotifierProvider(create: (_) => ProviderDetailsController()),
            ChangeNotifierProvider(create: (_) => ProviderOrdersController()),
            ChangeNotifierProvider(create: (_) => LocationController()),
            ChangeNotifierProvider(create: (_) => ReviewController()),
            ChangeNotifierProvider(create: (_) => WalletController()),
            ChangeNotifierProvider(create: (_) => ChatController()),
            ChangeNotifierProvider(create: (_) => BookingController()),
            ChangeNotifierProvider(create: (_) => StatisticsController()),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            useInheritedMediaQuery: true,
            theme: ThemeData(
              primaryColor: Colors.blue,
              useMaterial3: true,
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Colors.black54,
              ),
            ),
            routes: AppRoutes.routes,
            home: _getInitialScreen(),
          ),
        );
      },
    );
  }

  Widget _getInitialScreen() {
    if (!AuthController.isLoggedIn) {
      return const GetStartedScreen();
    }

    if (AuthController.activeRole == 'professional') {
      return const ProviderBottomNavigationScreen();
    } else {
      return const BottomNavigationScreen();
    }
  }
}
