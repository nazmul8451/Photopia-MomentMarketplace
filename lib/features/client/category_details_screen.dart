import 'package:flutter/material.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';
import 'package:photopia/features/client/widgets/category_bar.dart';
import 'package:photopia/features/client/widgets/search_header.dart';
import 'package:photopia/features/client/widgets/service_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:photopia/controller/client/service_list_controller.dart';
import 'package:provider/provider.dart';
import 'package:photopia/data/models/service_list_model.dart';
import 'package:photopia/controller/client/favorites_controller.dart';

class CategoryDetailsScreen extends StatefulWidget {
  const CategoryDetailsScreen({super.key});
  static const String name = "category-details";

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceListController>().getAllServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(15).r,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  SearchHeader(
                    onFilterApplied: (filters) {
                      final serviceCtrl = context.read<ServiceListController>();
                      final favCtrl = context.read<FavoritesController>();
                      
                      final bool favoritesOnly = filters['favoritesOnly'] == true;
                      
                      if (favoritesOnly) {
                        // Get IDs of all favorite posts
                        final List<String> favoriteIds = favCtrl.favoritePosts
                            .map((p) => (p['_id'] ?? p['id'] ?? '').toString())
                            .where((id) => id.isNotEmpty)
                            .toList();
                        
                        serviceCtrl.applyFavoritesFilter(true, favoriteIds);
                      } else {
                        serviceCtrl.resetFilters();
                        // You can still call getAllServices if needed for sync
                        // serviceCtrl.getAllServices(); 
                      }
                    },
                  ),

                  SizedBox(height: 5.h),
                ],
              ),
            ),
            // Scrollable Grid Results
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 15.h,
                        crossAxisSpacing: 15.w,
                        childAspectRatio:
                            0.52, // Safe height for all screen sizes
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Consumer<ServiceListController>(
                            builder: (context, controller, child) {
                              if (controller.isLoading) {
                                return const ServiceCardSkeleton();
                              }

                              if (controller.services.isEmpty) {
                                // If no services, we might want to show a message,
                                // but since this is in a grid, it's tricky.
                                // For now, return skeleton if still "loading" in a sense
                                // or just an empty container.
                                return const SizedBox();
                              }

                              final dynamic service = controller
                                  .services[index % controller.services.length];
                              return ServiceCard(
                                id: (service is ServiceItem) ? service.sId : service['_id']?.toString(),
                                title: (service is ServiceItem) ? (service.title ?? '') : (service['title']?.toString() ?? ''),
                                subtitle: (service is ServiceItem) 
                                    ? (service.providerId?.name ?? 'Professional')
                                    : (service['providerId']?['name'] ?? 'Professional'),
                                imageUrl: (service is ServiceItem) ? (service.coverMedia ?? '') : (service['coverMedia']?.toString() ?? ''),
                                rating: (service is ServiceItem) ? (service.rating ?? 0.0) : (double.tryParse(service['rating']?.toString() ?? '0.0') ?? 0.0),
                                reviews: (service is ServiceItem) ? (service.reviews ?? 0) : (int.tryParse(service['reviews']?.toString() ?? '0') ?? 0),
                                priceRange: (service is ServiceItem) 
                                    ? "€${service.price ?? 0}"
                                    : "€${service['price'] ?? 0}",
                                price: (service is ServiceItem) ? service.price : (num.tryParse(service['price']?.toString() ?? '')),
                                currency: (service is ServiceItem) ? service.currency : service['currency']?.toString(),
                                providerId: (service is ServiceItem) 
                                    ? service.providerId?.sId
                                    : service['providerId']?['_id']?.toString(),
                              );
                            },
                          );
                        },
                        childCount:
                            context.watch<ServiceListController>().isLoading
                            ? 6
                            : context
                                  .watch<ServiceListController>()
                                  .services
                                  .length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
