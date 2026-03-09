import 'package:flutter/material.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';
import 'package:photopia/features/client/widgets/category_bar.dart';
import 'package:photopia/features/client/widgets/search_header.dart';
import 'package:photopia/features/client/widgets/service_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:photopia/controller/client/service_list_controller.dart';
import 'package:provider/provider.dart';

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
                      // Handle filtering logic here
                      context.read<ServiceListController>().getAllServices();
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

                              final service = controller
                                  .services[index % controller.services.length];
                              return ServiceCard(
                                id: service.sId,
                                providerId: service.providerId?.sId,
                                title: service.title ?? '',
                                subtitle:
                                    service.providerId?.name ?? 'Professional',
                                imageUrl: service.coverMedia ?? '',
                                rating: service.rating ?? 0.0,
                                reviews: service.reviews ?? 0,
                                priceRange: "€${service.price ?? 0}",
                                tags:
                                    const [], // API model has tags, but let's keep it simple for now
                                isPremium: false,
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
