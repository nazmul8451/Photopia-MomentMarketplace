import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/widgets/shimmer_skeletons.dart';
import 'package:photopia/features/client/service_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/favorites_controller.dart';
import 'package:photopia/core/widgets/custom_network_image.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/utils/guest_dialog_helper.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
class ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final double rating;
  final int reviews;
  final String priceRange;
  final num? price;
  final String? currency;
  final List<String> tags;
  final bool isPremium;
  final bool isLoading;
  final dynamic id;
  final dynamic providerId;

  const ServiceCard({
    super.key,
    this.title = '',
    this.subtitle = '',
    this.imageUrl = '',
    this.rating = 0.0,
    this.reviews = 0,
    this.priceRange = '',
    this.price,
    this.currency,
    this.tags = const [],
    this.isPremium = false,
    this.isLoading = false,
    this.id,
    this.providerId,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ServiceCardSkeleton();
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailsScreen(
              service: {
                'title': title,
                'subtitle': subtitle,
                'imageUrl': imageUrl,
                'rating': rating,
                'reviews': reviews,
                'priceRange': priceRange,
                'price': price,
                'currency': currency,
                'tags': tags,
                'isPremium': isPremium,
                'id': id,
                '_id': id,
                'providerId': providerId,
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16).r,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Take minimum space needed
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.1, // Fixed aspect ratio for the image
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16).r,
                    ),
                    child: (imageUrl.isNotEmpty)
                        ? CustomNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                          )
                        : FutureBuilder<NetworkResponse>(
                            future: NetworkCaller.getRequest(url: Urls.getSingleList(id), requireAuth: false),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(color: Colors.grey[200], alignment: Alignment.center, child: Text('...', style: TextStyle(fontSize: 10.sp)));
                              }
                              String? fetchedUrl;
                              String errorMsg = '';
                              if (snapshot.hasError) {
                                errorMsg = 'E:${snapshot.error}';
                              } else if (snapshot.hasData && !snapshot.data!.isSuccess) {
                                errorMsg = 'Code:${snapshot.data!.statusCode}';
                              } else if (snapshot.hasData && snapshot.data!.isSuccess && snapshot.data!.body != null) {
                                final data = snapshot.data!.body!['data'];
                                if (data != null) {
                                  if (data['coverMedia'] != null) {
                                    fetchedUrl = data['coverMedia'];
                                  } else if (data['gallery'] != null && (data['gallery'] as List).isNotEmpty) {
                                    fetchedUrl = (data['gallery'] as List).first;
                                  } else {
                                    errorMsg = 'No Img';
                                  }
                                } else {
                                  errorMsg = 'Null Data';
                                }
                              }
                              
                              if (fetchedUrl != null && fetchedUrl.isNotEmpty) {
                                return CustomNetworkImage(
                                  imageUrl: fetchedUrl,
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return const CustomNetworkImage(
                                  imageUrl: '',
                                  fit: BoxFit.cover,
                                );
                              }
                            },
                          ),
                  ),
                ),
                if (isPremium)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20).r,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars, color: Colors.orange, size: 10.sp),
                          SizedBox(width: 2.w),
                          Text(
                            'Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.sp.clamp(9, 10),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Consumer<FavoritesController>(
                    builder: (context, controller, child) {
                      bool isFavorite = controller.isPostFavorite(id);
                      return GestureDetector(
                        onTap: () {
                          if (!AuthController.isLoggedIn) {
                            GuestDialogHelper.showGuestDialog(context);
                            return;
                          }
                          controller.toggleFavorite(
                            serviceId: id,
                            optimisticData: {
                              '_id': id,
                              'id': id,
                              'title': title,
                              'subtitle': subtitle,
                              'imageUrl': imageUrl,
                              'rating': rating,
                              'reviews': reviews,
                              'priceRange': priceRange,
                              'tags': tags,
                              'isPremium': isPremium,
                              'providerId': providerId,
                            },
                          );
                        },
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 0.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                                size: 18.sp.clamp(18, 20),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // Info Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 13.sp.clamp(13, 14),
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11.sp.clamp(11, 12),
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.orange,
                          size: 12.sp.clamp(12, 13),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            fontSize: 11.sp.clamp(11, 12),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            ' ($reviews)',
                            style: TextStyle(
                              fontSize: 11.sp.clamp(11, 12),
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 4.w,
                      runSpacing: 4.h,
                      children: tags
                          .take(2)
                          .map(
                            (tag) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4).r,
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 9.sp.clamp(9, 10),
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    Text(
                      priceRange,
                      style: TextStyle(
                        fontSize: 12.sp.clamp(12, 13),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
