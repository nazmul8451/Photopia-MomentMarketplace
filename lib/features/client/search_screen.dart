import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/category_details_screen.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/core/constants/app_sizes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Wedding', 'icon': Icons.favorite, 'color': 0xFFFFE4E1},
    {'name': 'Portrait', 'icon': Icons.person, 'color': 0xFFE0F7FA},
    {'name': 'Events', 'icon': Icons.event, 'color': 0xFFF3E5F5},
    {'name': 'Commercial', 'icon': Icons.business, 'color': 0xFFE8F5E9},
    {'name': 'Fashion', 'icon': Icons.checkroom, 'color': 0xFFFFF3E0},
    {'name': 'Baby', 'icon': Icons.child_care, 'color': 0xFFFCE4EC},
    {'name': 'Travel', 'icon': Icons.flight, 'color': 0xFFE3F2FD},
    {'name': 'Food', 'icon': Icons.restaurant, 'color': 0xFFF1F8E9},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCategoryDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoryDetailsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Search',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTypography.h1,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              height: AppSizes.fieldHeight,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for photographers...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: AppTypography.bodyMedium,
                  ),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey[500], size: 24.sp),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Categories Header
            Text(
              'Browse Categories',
              style: TextStyle(
                fontSize: AppTypography.h2,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.h),

            // Categories Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 1.5,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return GestureDetector(
                    onTap: _navigateToCategoryDetails,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(category['color']),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'],
                            size: 32.sp,
                            color: Colors.black87,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            category['name'],
                            style: TextStyle(
                              fontSize: AppTypography.bodyMedium,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
