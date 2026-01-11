import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/category_details_screen.dart';

class CategoryBar extends StatefulWidget {
  const CategoryBar({super.key});

  @override
  State<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'title': 'All', 'icon': Icons.grid_view_rounded},
    {'title': 'Photography', 'icon': Icons.photo_camera_outlined},
    {'title': 'Video', 'icon': Icons.videocam_outlined},
    {'title': 'Video', 'icon': Icons.video_collection_outlined}, 
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35.h.clamp(35, 45),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          bool isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = index);
            },
            child: Container(
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
                    _categories[index]['icon'],
                    size: 18.sp,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _categories[index]['title'],
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
