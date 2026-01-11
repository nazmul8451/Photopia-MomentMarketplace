import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/widgets/search_header.dart';
import 'package:photopia/features/client/widgets/service_card.dart';

class CategoryDetailsScreen extends StatefulWidget {
  const CategoryDetailsScreen({super.key});

  static const String name = "category-details-screen";

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
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
            // Sticky Search Header with Shadow
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const SearchHeader(),
            ),
            // Scrollable Grid Results
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 100.h),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 15.h,
                        crossAxisSpacing: 15.w,
                        childAspectRatio: 0.6, // Taller for more info
                      ),
                      delegate: SliverChildListDelegate([
                        const ServiceCard(
                          title: 'Romantic Wedding Photography',
                          subtitle: 'Emma Wilson',
                          imageUrl: 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?q=80&w=500',
                          rating: 4.9,
                          reviews: 127,
                          priceRange: '€800 - €2,500',
                          tags: ['Wedding', 'Outdoor'],
                          isPremium: true,
                        ),
                        const ServiceCard(
                          title: 'Professional Portrait Sessions',
                          subtitle: 'Marco Silva',
                          imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=500',
                          rating: 4.8,
                          reviews: 89,
                          priceRange: '€150 - €500',
                          tags: ['Portrait', 'Studio'],
                        ),
                        const ServiceCard(
                          title: 'Corporate Video Production',
                          subtitle: 'Tech Media Studio',
                          imageUrl: 'https://images.unsplash.com/photo-1522071823991-b3b652bb0913?q=80&w=500',
                          rating: 5.0,
                          reviews: 45,
                          priceRange: '€1,200 - €5,000',
                          tags: ['Corporate', 'Video'],
                        ),
                        const ServiceCard(
                          title: 'Aerial Drone Photography',
                          subtitle: 'SkyView Productions',
                          imageUrl: 'https://images.unsplash.com/photo-1508614589041-895b88991e3e?q=80&w=500',
                          rating: 4.9,
                          reviews: 62,
                          priceRange: '€300 - €1,200',
                          tags: ['Drone', 'Aerial'],
                          isPremium: true,
                        ),
                        const ServiceCard(
                          title: 'Fashion & Editorial Photography',
                          subtitle: 'Lucia Rossi',
                          imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=500',
                          rating: 4.8,
                          reviews: 103,
                          priceRange: '€500 - €2,000',
                          tags: ['Fashion', 'Editorial'],
                          isPremium: true,
                        ),
                        const ServiceCard(
                          title: 'Product Photography Studio',
                          subtitle: 'Creative Lens Co.',
                          imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=500',
                          rating: 4.7,
                          reviews: 78,
                          priceRange: '€200 - €800',
                          tags: ['Product', 'Studio'],
                        ),
                      ]),
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