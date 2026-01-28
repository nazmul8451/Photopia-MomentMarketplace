import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:photopia/app.dart';
import 'package:photopia/features/client/home_page.dart';

import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const Photopia(),
    ),
  );
}



