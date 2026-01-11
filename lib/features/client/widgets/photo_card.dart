import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhotoCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool hasBadges;

  const PhotoCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.hasBadges = false,
  });

  @override
  Widget build(BuildContext context) {
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
                    image: NetworkImage(imageUrl),
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
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
