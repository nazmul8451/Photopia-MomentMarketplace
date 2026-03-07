import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyLoader extends StatelessWidget {
  final Color color;
  final double size;

  const MyLoader({super.key, this.color = Colors.black87, this.size = 50.0});

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(color: color, size: size);
  }
}
