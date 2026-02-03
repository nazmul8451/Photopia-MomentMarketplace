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
      {'name': 'Wedding', 'icon': Icons.favorite, 'color': 0xFFFFE4E1},
      {'name': 'Portrait', 'icon': Icons.person, 'color': 0xFFE0F7FA},
      {'name': 'Events', 'icon': Icons.event, 'color': 0xFFF3E5F5},
      {'name': 'Fashion', 'icon': Icons.checkroom, 'color': 0xFFFFF3E0},
      {'name': 'Baby', 'icon': Icons.child_care, 'color': 0xFFFCE4EC},
      {'name': 'Food', 'icon': Icons.restaurant, 'color': 0xFFF1F8E9},
    ],
    'Video': [
      {'name': 'Music Video', 'icon': Icons.music_video, 'color': 0xFFE3F2FD},
      {'name': 'Documentary', 'icon': Icons.movie, 'color': 0xFFF3E5F5},
      {'name': 'Commercial', 'icon': Icons.business, 'color': 0xFFE8F5E9},
      {'name': 'Event Coverage', 'icon': Icons.videocam, 'color': 0xFFFFE4E1},
      {'name': 'Travel Vlog', 'icon': Icons.flight, 'color': 0xFFFFF3E0},
      {'name': 'Interview', 'icon': Icons.mic, 'color': 0xFFE0F7FA},
    ],
    'Video Editing': [
      {'name': 'Color Grading', 'icon': Icons.palette, 'color': 0xFFFCE4EC},
      {'name': 'Motion Graphics', 'icon': Icons.animation, 'color': 0xFFF1F8E9},
      {'name': 'VFX', 'icon': Icons.auto_awesome, 'color': 0xFFE3F2FD},
      {'name': 'Sound Design', 'icon': Icons.graphic_eq, 'color': 0xFFF3E5F5},
      {'name': 'Transitions', 'icon': Icons.swap_horiz, 'color': 0xFFE8F5E9},
      {'name': 'Subtitles', 'icon': Icons.subtitles, 'color': 0xFFFFE4E1},
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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 1.5,
                ),
                itemCount: _currentCategories.length,
                itemBuilder: (context, index) {
                  final category = _currentCategories[index];
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
          ),
        ],
      ),
    );
  }
}
