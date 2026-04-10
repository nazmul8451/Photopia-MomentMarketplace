import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/category_details_screen.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/client/widgets/category_bar.dart';
import 'package:photopia/features/client/widgets/search_header.dart';
import 'package:photopia/features/client/search_result_screen.dart';
import 'package:photopia/features/client/widgets/service_card.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/service_list_controller.dart';

class SearchScreen extends StatefulWidget {
  static const String name = '/search';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedCategoryIndex = 0;
  bool _isSearching = false;
  Map<String, dynamic> _currentFilters = {};

  final List<String> _categoryTabs = ['Photo', 'Video', 'Video Editing'];

  void _onSearch(Map<String, dynamic> filters) {
    final searchTerm = filters['searchTerm']?.toString() ?? '';

    if (searchTerm.isEmpty && filters.length == 1) {
      _clearSearch();
      return;
    }

    setState(() {
      _isSearching = true;
      _currentFilters = filters;
    });
    // Trigger API call via controller
    context.read<ServiceListController>().getAllServices(filters: filters);
  }

  void _clearSearch() {
    setState(() {
      _isSearching = false;
      _currentFilters = {};
    });
    // Optional: reset data if needed, or keep it.
    // Usually, we just toggle back to categories.
  }

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
                SearchHeader(onFilterApplied: _onSearch),
                CategoryBar(
                  selectedIndex: _selectedCategoryIndex,
                  onCategorySelected: (index) {
                    setState(() {
                      _selectedCategoryIndex = index;
                      // When a category is selected, we can either search for it
                      // or just clear the search view.
                      _clearSearch();
                    });
                  },
                ),
                SizedBox(height: 15.h),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Conditional View: Search Results or Browse Categories
          if (_isSearching)
            _buildSearchResults()
          else ...[
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
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: Consumer<ServiceListController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 20.h,
                childAspectRatio: 0.6,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => const ServiceCardSkeleton(),
            );
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  controller.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                ),
              ),
            );
          }

          final results = controller.services;

          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60.sp, color: Colors.grey[300]),
                  SizedBox(height: 16.h),
                  Text(
                    'No services found',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 20.h),
                  TextButton(
                    onPressed: _clearSearch,
                    child: const Text('Back to Categories'),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search Results',
                      style: TextStyle(
                        fontSize: AppTypography.h2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _clearSearch,
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 20.h,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final service = results[index];
                    return ServiceCard(
                      id: service.sId ?? '',
                      title: service.title ?? '',
                      subtitle: service.providerId?.name ?? 'Professional',
                      imageUrl: service.coverMedia ?? '',
                      rating: service.rating ?? 0.0,
                      reviews: service.reviews ?? 0,
                      price: service.price,
                      currency: service.currency,
                      providerId: service.providerId?.sId,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
