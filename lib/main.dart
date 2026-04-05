import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:photopia/app.dart';
import 'package:photopia/features/client/home_page.dart';

import 'package:get_storage/get_storage.dart';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:photopia/controller/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Replace with your actual Stripe Publishable Key
  Stripe.publishableKey = "pk_test_51RcvK8GdOsJASBMC9aDK1onP8kTVwAxve4385Mr09r2Edd1fxcbSWD1y5DCclahZ7MHa0hf1eBnsnq16bWavPRY400W2WfumAa";
  
  await GetStorage.init();

  await AuthController.initialize();
  runApp(DevicePreview(enabled: false, builder: (context) => const Photopia()));
}
