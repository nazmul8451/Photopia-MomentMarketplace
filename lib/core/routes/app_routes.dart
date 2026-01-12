import 'package:photopia/features/client/home_page.dart';
import 'package:photopia/features/client/category_details_screen.dart';
import 'package:photopia/features/client/search_filter_screen.dart';
import 'package:photopia/features/client/notification_screen.dart';
import 'package:photopia/features/client/BottomNavigation.dart';

class AppRoutes {
  static const String home_page = MyHomePage.name;
  static const String category_details = CategoryDetailsScreen.name;
  static const String search_filter = SearchFilterScreen.name;
  static const String notification = NotificationScreen.name;
  static const String bottom_navigation = BottomNavigationScreen.name;

  static final routes = {
    home_page: (context) => const MyHomePage(),
    category_details: (context) => const CategoryDetailsScreen(),
    search_filter: (context) => const SearchFilterScreen(),
    notification: (context) => const NotificationScreen(),
    bottom_navigation: (context) => const BottomNavigationScreen(),
  };
}