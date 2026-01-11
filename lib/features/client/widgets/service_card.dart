import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final double rating;
  final int reviews;
  final String priceRange;
  final List<String> tags;
  final bool isPremium;

  const ServiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.rating = 4.9,
    this.reviews = 0,
    required this.priceRange,
    required this.tags,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16).r,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Take minimum space needed
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.1, // Fixed aspect ratio for the image
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16).r),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (isPremium)
                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20).r,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.stars, color: Colors.orange, size: 10.sp),
                        SizedBox(width: 2.w),
                        Text(
                          'Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.red,
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),
          // Info Section
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.sp.clamp(13, 14),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.sp.clamp(11, 12),
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 12.sp),
                      SizedBox(width: 4.w),
                      Text(
                        rating.toString(),
                        style: TextStyle(
                          fontSize: 11.sp.clamp(11, 12),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          ' ($reviews)',
                          style: TextStyle(
                            fontSize: 11.sp.clamp(11, 12),
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 4.w,
                    runSpacing: 4.h,
                    children: tags
                        .take(2)
                        .map((tag) => Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4).r,
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 9.sp.clamp(9, 10),
                                  color: Colors.grey[700],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  Text(
                    priceRange,
                    style: TextStyle(
                      fontSize: 12.sp.clamp(12, 13),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
