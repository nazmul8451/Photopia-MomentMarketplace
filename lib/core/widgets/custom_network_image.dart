import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomNetworkImage extends StatelessWidget {
  final dynamic imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Color? backgroundColor;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    String url = "";
    if (imageUrl == null) {
      url = "";
    } else if (imageUrl is String) {
      url = imageUrl;
    } else if (imageUrl is Map && imageUrl.containsKey('url')) {
      url = imageUrl['url']?.toString() ?? "";
    } else {
      url = imageUrl.toString();
    }

    final bool isAsset = url.startsWith('assets/');
    
    return ClipRRect(
      borderRadius: shape == BoxShape.circle 
          ? BorderRadius.circular(1000) 
          : (borderRadius ?? BorderRadius.zero),
      child: isAsset 
          ? Image.asset(
              url,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorPlaceholder(width, height);
              },
            )
          : Image.network(
              url,
              width: width,
              height: height,
              fit: fit,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                if (frame == null) {
                  return _buildShimmer(width, height);
                }
                return child;
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildShimmer(width, height);
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorPlaceholder(width, height);
              },
            ),
    );
  }

  Widget _buildShimmer(double? w, double? h) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300] ?? Colors.grey,
      highlightColor: Colors.grey[100] ?? Colors.white,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: shape,
          borderRadius: shape == BoxShape.circle ? null : (borderRadius ?? BorderRadius.zero),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(double? w, double? h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[200],
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : (borderRadius ?? BorderRadius.zero),
      ),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey[400],
          size: (w != null && h != null) ? (w < h ? w * 0.4 : h * 0.4) : 24.sp,
        ),
      ),
    );
  }
}
