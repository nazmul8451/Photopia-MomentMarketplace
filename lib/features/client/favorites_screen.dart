import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/controller/client/favorites_controller.dart';
import 'package:photopia/features/client/widgets/service_card.dart';
import 'package:photopia/features/client/widgets/provider_card.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatefulWidget {
  static const String name = '/favorites';
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Fetch favorites on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesController>().fetchFavorites();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabSelector(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildPostsList(), _buildProvidersList()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 10.h),
      child: Row(
        children: [
          Icon(Icons.bookmark_outline, size: 24.sp),
          SizedBox(width: 8.w),
          Text(
            'Favorites',
            style: TextStyle(
              fontSize: 20.sp.clamp(20, 22),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10).r,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
        tabs: [
          Consumer<FavoritesController>(
            builder: (context, controller, child) {
              return Tab(text: 'Posts (${controller.favoritePosts.length})');
            },
          ),
          Consumer<FavoritesController>(
            builder: (context, controller, child) {
              return Tab(
                text: 'Providers (${controller.favoriteProviders.length})',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return Consumer<FavoritesController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return GridView.builder(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15.h,
              crossAxisSpacing: 15.w,
              childAspectRatio: 0.55,
            ),
            itemCount: 4,
            itemBuilder: (context, index) => ServiceCardSkeleton(),
          );
        }
        if (controller.favoritePosts.isEmpty) {
          return _buildEmptyState('No favorite posts yet');
        }
        return GridView.builder(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15.h,
            crossAxisSpacing: 15.w,
            childAspectRatio: 0.55,
          ),
          itemCount: controller.favoritePosts.length,
          itemBuilder: (context, index) {
            final service = controller.favoritePosts[index];
            return ServiceCard(
              id: service['_id'] ?? service['id'],
              title: service['title'] ?? '',
              subtitle:
                  service['subtitle'] ?? (service['providerId']?['name'] ?? ''),
              imageUrl: service['coverMedia'] ?? service['imageUrl'] ?? '',
              rating: (service['rating'] ?? 0.0).toDouble(),
              reviews: service['reviews'] ?? 0,
              priceRange:
                  service['priceRange'] ??
                  '${service['currency'] ?? '\$'} ${service['price'] ?? 0}',
              tags: List<String>.from(service['tags'] ?? []),
              isPremium: service['isPremium'] ?? false,
              providerId: service['providerId'] is Map
                  ? service['providerId']['_id']
                  : service['providerId'],
            );
          },
        );
      },
    );
  }

  Widget _buildProvidersList() {
    return Consumer<FavoritesController>(
      builder: (context, controller, child) {
        if (controller.isLoading) {
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
            itemCount: 3,
            itemBuilder: (context, index) => ProviderCardSkeleton(),
          );
        }
        if (controller.favoriteProviders.isEmpty) {
          return _buildEmptyState('No favorite providers yet');
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
          itemCount: controller.favoriteProviders.length,
          itemBuilder: (context, index) {
            final provider = controller.favoriteProviders[index];
            return ProviderCard(provider: provider);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
