import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';

class CategoryBar extends StatefulWidget {
  final bool isLoading;
  const CategoryBar({super.key, this.isLoading = false});

  @override
  State<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.grid_view_rounded, 'label': 'All'},
    {'icon': Icons.favorite_border_rounded, 'label': 'Wedding'},
    {'icon': Icons.person_outline_rounded, 'label': 'Portrait'},
    {'icon': Icons.business_center_outlined, 'label': 'Corporate'},
    {'icon': Icons.camera_alt_outlined, 'label': 'Product'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35.h.clamp(35, 45),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: widget.isLoading ? 5 : categories.length,
        itemBuilder: (context, index) {
          if (widget.isLoading) {
            return Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: const CategoryChipSkeleton(),
            );
          }
          final category = categories[index];
          bool isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = index);
            },
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(25).r,
                border: Border.all(
                  color: isSelected ? Colors.black : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    categories[index]['icon'],
                    size: 18.sp,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    categories[index]['label'],
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
