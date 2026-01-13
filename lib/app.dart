import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/home_page.dart';
import 'package:photopia/features/client/BottomNavigation.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/favorites_controller.dart';


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
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            useInheritedMediaQuery: true,
            // locale: DevicePreview.locale(context),
            // builder: DevicePreview.appBuilder,
            theme: ThemeData(
              primaryColor: Colors.blue,
              useMaterial3: true,
  
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Colors.black54,
              ),
            ),
            home:  BottomNavigationScreen(), 
          ),
        );
      },
    );
  }
}