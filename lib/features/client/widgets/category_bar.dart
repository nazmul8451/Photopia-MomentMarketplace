import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';

import 'package:photopia/data/models/category_model.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/category_controller.dart';

class CategoryBar extends StatelessWidget {
  final bool isLoading;
  final String? selectedCategoryId;
  final Function(String?)? onCategorySelected;

  const CategoryBar({
    super.key,
    this.isLoading = false,
    this.selectedCategoryId,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categoryController = context.watch<CategoryController>();
    final categories = categoryController.rootCategories;

    return SizedBox(
      height: 40.h.clamp(35, 45),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: isLoading || categoryController.isLoading ? 5 : categories.length + 1,
        itemBuilder: (context, index) {
          if (isLoading || categoryController.isLoading) {
            return Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: const CategoryChipSkeleton(),
            );
          }

          // Index 0 is "All"
          final bool isAll = index == 0;
          final CategoryModel? category = isAll ? null : categories[index - 1];
          final String label = isAll ? 'All' : category!.name;
          final bool isSelected = isAll 
              ? selectedCategoryId == null 
              : selectedCategoryId == category!.id;

          return GestureDetector(
            onTap: () {
              if (onCategorySelected != null) {
                onCategorySelected!(isAll ? null : category!.id);
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
                  if (!isAll && category?.icon != null) ...[
                     // Handle icon if needed, for now use default if no icon
                     Icon(
                        Icons.category_outlined,
                        size: 18.sp.clamp(18, 20),
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      SizedBox(width: 8.w),
                  ] else if (isAll) ...[
                      Icon(
                        Icons.grid_view_outlined,
                        size: 18.sp.clamp(18, 20),
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      SizedBox(width: 8.w),
                  ],
                  Text(
                    label,
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
