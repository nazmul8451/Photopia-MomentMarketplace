import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dart:io';
import 'package:photopia/core/widgets/exif_aware_network_image.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String? imageUrl;
  final String? filePath;
  final ImageProvider? imageProvider; // Fallback
  final String? tag;

  const FullScreenImageViewer({
    super.key,
    this.imageUrl,
    this.filePath,
    this.imageProvider,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Interactive Viewer for zoom and pan
          Center(
            child: Hero(
              tag: tag ?? 'image_hero_${imageUrl ?? filePath ?? imageProvider.hashCode}',
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: _buildImage(),
              ),
            ),
          ),
          
          // Close button
          Positioned(
            top: 40.h,
            right: 20.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return ExifAwareNetworkImage(
        url: imageUrl!,
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.contain,
      );
    } else if (filePath != null || (imageUrl != null && !imageUrl!.startsWith('http'))) {
      final path = filePath ?? imageUrl!;
      return Image.file(
        File(path),
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (imageProvider != null) {
      return Image(
        image: imageProvider!,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return const Center(child: Icon(Icons.broken_image, color: Colors.white));
  }
}
