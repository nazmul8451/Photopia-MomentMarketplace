import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/controller/provider/my_listing_controller.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/core/widgets/custom_network_image.dart';
import 'package:photopia/core/widgets/my_loader.dart';
import 'package:photopia/features/provider/screen/provider_create_listing_screen.dart';
import 'package:provider/provider.dart';

class ProviderListingDetailsScreen extends StatefulWidget {
  final String listingId;

  const ProviderListingDetailsScreen({super.key, required this.listingId});

  @override
  State<ProviderListingDetailsScreen> createState() =>
      _ProviderListingDetailsScreenState();
}

class _ProviderListingDetailsScreenState
    extends State<ProviderListingDetailsScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyListingController>().getSingleListing(widget.listingId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Listing Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTypography.h1,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<MyListingController>(
        builder: (context, controller, child) {
          if (controller.isSingleListingProgress) {
            return Center(child: MyLoader());
          }

          final listing = controller.singleListingData;

          if (listing == null) {
            return Center(
              child: Text(
                controller.errorMessage ?? 'Listing not found',
                style: TextStyle(fontSize: AppTypography.bodyLarge),
              ),
            );
          }

          // Build image list from coverMedia + gallery
          final List<String> images = [];

          // Always add coverMedia first if it exists
          if (listing.coverMedia != null && listing.coverMedia!.isNotEmpty) {
            final path = listing.coverMedia!;
            images.add(path.startsWith('http') ? path : '${Urls.baseUrl}$path');
          }

          // Add all gallery images
          if (listing.gallery != null && listing.gallery!.isNotEmpty) {
            for (final img in listing.gallery!) {
              if (img != null && img.toString().isNotEmpty) {
                final path = img.toString();
                final url = path.startsWith('http')
                    ? path
                    : '${Urls.baseUrl}$path';
                if (!images.contains(url)) {
                  images.add(url);
                }
              }
            }
          }

          debugPrint('📸 Image count: ${images.length}');
          debugPrint('📸 Images: $images');

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Slider
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.r),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 200.h,
                        width: double.infinity,
                        child: images.isEmpty
                            ? Container(
                                height: 200.h,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image,
                                  size: 50.sp,
                                  color: Colors.grey[400],
                                ),
                              )
                            : PageView.builder(
                                controller: _pageController,
                                itemCount: images.length,
                                onPageChanged: (index) {
                                  setState(() => _currentImageIndex = index);
                                },
                                itemBuilder: (context, index) {
                                  return CustomNetworkImage(
                                    imageUrl: images[index],
                                    height: 200.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                      ),
                      // Dot Indicators
                      if (images.length > 1)
                        Positioned(
                          bottom: 10.h,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.symmetric(horizontal: 3.w),
                                width: _currentImageIndex == i ? 18.w : 6.w,
                                height: 6.h,
                                decoration: BoxDecoration(
                                  color: _currentImageIndex == i
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(3.r),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Title and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        listing.title ?? 'No Title',
                        style: TextStyle(
                          fontSize: AppTypography.h1,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        listing.status ?? 'Active',
                        style: TextStyle(
                          fontSize: AppTypography.bodySmall,
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Price and Duration
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${listing.currency ?? '\$'}${listing.price ?? 0}',
                      style: TextStyle(
                        fontSize: AppTypography.h1,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.circle, size: 4.sp, color: Colors.grey[400]),
                    SizedBox(width: 8.w),
                    Text(
                      listing.duration ?? 'per session',
                      style: TextStyle(
                        fontSize: AppTypography.bodyLarge,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Category Pill
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    listing.category?.name ?? 'Photography',
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                const Divider(color: Color(0xFFF0F0F0)),
                SizedBox(height: 20.h),

                // Description
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: AppTypography.h2,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  listing.description ?? 'No description provided.',
                  style: TextStyle(
                    fontSize: AppTypography.bodyLarge,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 20.h),

                const Divider(color: Color(0xFFF0F0F0)),
                SizedBox(height: 20.h),

                // Location
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: AppTypography.h2,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  listing.location?.address ??
                      '${listing.location?.city ?? ''}, ${listing.location?.country ?? ''}',
                  style: TextStyle(
                    fontSize: AppTypography.bodyLarge,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 20.h),

                const Divider(color: Color(0xFFF0F0F0)),
                SizedBox(height: 20.h),

                // Stats (Placeholders for now, as they are not in ProviderServiceModel)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '00',
                            style: TextStyle(
                              fontSize: AppTypography.h1,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Total Views',
                            style: TextStyle(
                              fontSize: AppTypography.bodySmall,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '00',
                            style: TextStyle(
                              fontSize: AppTypography.h1,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Bookings',
                            style: TextStyle(
                              fontSize: AppTypography.bodySmall,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),

                // Footer Buttons
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProviderCreateListingScreen(
                                existingListing: listing,
                              ),
                            ),
                          );
                          // If edit was successful, refresh the details
                          if (result == true && mounted) {
                            context
                                .read<MyListingController>()
                                .getSingleListing(widget.listingId);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(0, 50.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text(
                          'Edit Listing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTypography.h2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Container(
                      width: 50.h,
                      height: 50.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: null,
    );
  }
}
