import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';

class CategoryBar extends StatelessWidget {
  final bool isLoading;
  final int selectedIndex;
  final Function(int)? onCategorySelected;

  const CategoryBar({
    super.key,
    this.isLoading = false,
    this.selectedIndex = 0,
    this.onCategorySelected,
  });

  final List<Map<String, dynamic>> categories = const [
    {'icon': Icons.camera_alt_outlined, 'label': 'Photo'},
    {'icon': Icons.videocam_outlined, 'label': 'Video'},
    {'icon': Icons.video_library_outlined, 'label': 'Video Editing'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35.h.clamp(35, 45),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: isLoading ? 3 : categories.length,
        itemBuilder: (context, index) {
          if (isLoading) {
            return Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: const CategoryChipSkeleton(),
            );
          }
          final category = categories[index];
          bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              if (onCategorySelected != null) {
                onCategorySelected!(index);
              }
            },
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(25).r,
                border: Border.all(
                  color: isSelected
                      ? Colors.black
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    category['icon'],
                    size: 18.sp.clamp(18, 20),
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    category['label'],
                    style: TextStyle(
                      fontSize: 14.sp.clamp(14, 15),
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
