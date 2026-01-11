import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  static const String name = "home-page";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photopia'),
      ),
      body: Center(
        child: Text(
          'Responsive Text',
          style: TextStyle(fontSize: 24.sp),
        ),
      ),
    );
  }
}