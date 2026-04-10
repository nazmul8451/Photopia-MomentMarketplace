import 'package:flutter/material.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/widgets/exif_aware_network_image.dart';

class CustomNetworkImage extends StatelessWidget {
  final dynamic imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Color? backgroundColor;
  final Widget? placeholder;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.backgroundColor,
    this.placeholder,
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

    // Handle relative URLs logically
    if (url.isNotEmpty && !url.startsWith('http') && !url.startsWith('assets/')) {
      final String base = Urls.baseUrl.endsWith('/') 
          ? Urls.baseUrl.substring(0, Urls.baseUrl.length - 1) 
          : Urls.baseUrl;
      final String path = url.startsWith('/') ? url : '/$url';
      url = "$base$path";
    }

    final bool isAsset = url.startsWith('assets/');
    final bool isEmpty = url.isEmpty;
    
    if (isEmpty) {
      return _buildErrorPlaceholder(width, height);
    }
    
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
          : ExifAwareNetworkImage(
              url: url,
              width: width ?? double.infinity,
              height: height ?? double.infinity,
              fit: fit,
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
      child: placeholder != null ? Center(child: placeholder) : Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey[400],
          size: (w != null && h != null) ? (w < h ? w * 0.4 : h * 0.4) : 24.sp,
        ),
      ),
    );
  }
}
