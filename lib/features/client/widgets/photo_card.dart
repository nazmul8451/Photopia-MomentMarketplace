import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';

class PhotoCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool hasBadges;
  final bool isLoading;

  const PhotoCard({
    super.key,
    this.title = '',
    this.imageUrl = '',
    this.hasBadges = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ShimmerSkeleton(
        width: double.infinity,
        height: 180.h,
        borderRadius: BorderRadius.circular(16).r,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 1, // Square as per reference grid
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20).r,
                  image: DecorationImage(
                    image: AssetImage(imageUrl.startsWith('assets/') ? imageUrl : 'assets/images/img1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            if (hasBadges)
              Positioned(
                bottom: 10.h,
                left: 10.w,
                child: Row(
                  children: [
                    _buildAvatarBadge('E', Colors.blue),
                    Transform.translate(
                      offset: Offset(-8.w, 0),
                      child: _buildAvatarBadge('S', Colors.brown),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 10.h),
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp.clamp(14,15),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 1, // Allow up to 2 lines instead of 1
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarBadge(String text, Color color) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
