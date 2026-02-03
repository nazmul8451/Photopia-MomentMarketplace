import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/category_details_screen.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/client/widgets/category_bar.dart';
import 'package:photopia/features/client/widgets/search_header.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedCategoryIndex = 0;

  final List<String> _categoryTabs = ['Photo', 'Video', 'Video Editing'];

  // Categories organized by type
  final Map<String, List<Map<String, dynamic>>> _categoriesByType = {
    'Photo': [
      {'name': 'Interior Photography', 'image': 'assets/images/img1.png'},
      {'name': 'Portrait Photography', 'image': 'assets/images/img2.png'},
      {'name': 'Home Decor Shoots', 'image': 'assets/images/img3.png'},
      {'name': 'Product Photography', 'image': 'assets/images/img4.png'},
      {'name': 'Outdoor Photography', 'image': 'assets/images/img5.png'},
      {'name': 'Fashion Photography', 'image': 'assets/images/img6.png'},
      {'name': 'Wedding Photography', 'image': 'assets/images/img4.png'},
      {'name': 'Studio Photography', 'image': 'assets/images/img2.png'},
    ],
    'Video': [
      {'name': 'Music Video', 'image': 'assets/images/img3.png'},
      {'name': 'Documentary', 'image': 'assets/images/img5.png'},
      {'name': 'Commercial', 'image': 'assets/images/img1.png'},
      {'name': 'Event Coverage', 'image': 'assets/images/img6.png'},
      {'name': 'Travel Vlog', 'image': 'assets/images/img2.png'},
      {'name': 'Interview', 'image': 'assets/images/img4.png'},
    ],
    'Video Editing': [
      {'name': 'Color Grading', 'image': 'assets/images/img5.png'},
      {'name': 'Motion Graphics', 'image': 'assets/images/img3.png'},
      {'name': 'VFX', 'image': 'assets/images/img1.png'},
      {'name': 'Sound Design', 'image': 'assets/images/img4.png'},
    ],
  };

  void _navigateToCategoryDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoryDetailsScreen()),
    );
  }

  List<Map<String, dynamic>> get _currentCategories {
    return _categoriesByType[_categoryTabs[_selectedCategoryIndex]] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(15.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const SearchHeader(),
                CategoryBar(
                  selectedIndex: _selectedCategoryIndex,
                  onCategorySelected: (index) {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                ),
                SizedBox(height: 15.h),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Categories Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Browse Categories',
              style: TextStyle(
                fontSize: AppTypography.h2,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Categories Grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 20.h,
                childAspectRatio: 0.85,
              ),
              itemCount: _currentCategories.length,
              itemBuilder: (context, index) {
                final category = _currentCategories[index];
                return GestureDetector(
                  onTap: _navigateToCategoryDetails,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            image: DecorationImage(
                              image: AssetImage(category['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        category['name'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppTypography.bodySmall,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
