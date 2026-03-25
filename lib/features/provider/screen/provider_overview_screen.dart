import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/provider/screen/provider_create_listing_screen.dart';
import 'package:photopia/features/provider/screen/provider_listing_details_screen.dart';
import 'package:photopia/controller/provider/my_listing_controller.dart';
import 'package:photopia/controller/provider/service_controller.dart';
import 'package:photopia/controller/common/bottom_nav_controller.dart';
import 'package:photopia/features/provider/widgets/provider_overview_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:photopia/data/models/my_listing_model.dart';
import 'package:photopia/core/widgets/custom_snacbar.dart';

class ProviderOverviewScreen extends StatefulWidget {
  const ProviderOverviewScreen({super.key});

  @override
  State<ProviderOverviewScreen> createState() => _ProviderOverviewScreenState();
}

class _ProviderOverviewScreenState extends State<ProviderOverviewScreen> {
  String _selectedStatus = 'Active'; // Initialize with a default value

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyListingController>().getMyListings();
    });
  }

  List<Listing> _getFilteredListings(List<Listing> listings) {
    return listings
        .where(
          (listing) =>
              listing.status?.toLowerCase() == _selectedStatus.toLowerCase(),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Listings',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: AppTypography.h1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProviderCreateListingScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.add, size: 18.sp, color: Colors.white),
                label: Text(
                  'Create',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTypography.bodyLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Consumer<MyListingController>(
        builder: (context, controller, child) {
          if (controller.isProgress) {
            return const ProviderOverviewShimmer();
          }

          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          final listings = _getFilteredListings(controller.listings);

          return RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.lightImpact();
              await controller.getMyListings();
            },
            color: Colors.black,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  // Status Tabs
                  Row(
                    children: [
                      _buildStatusTab('Active'),
                      SizedBox(width: 12.w),
                      _buildStatusTab('Drafts'),
                      SizedBox(width: 12.w),
                      _buildStatusTab('Past'),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Listings
                  if (listings.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50.h),
                        child: Text(
                          'No $_selectedStatus listings found',
                          style: TextStyle(
                            fontSize: AppTypography.bodyLarge,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    ...listings.map((listing) => _buildListingCard(listing)),
                  SizedBox(height: 20.h),
                  // Overall Statistics
                  _buildStatisticsSection(controller),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTab(String status) {
    bool isSelected = _selectedStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStatus = status),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1F1F1F)
                : const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontSize: AppTypography.bodyLarge,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListingCard(Listing listing) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  listing.title ?? 'No Title',
                  style: TextStyle(
                    fontSize: AppTypography.h2,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                listing.category?.name ?? 'No Category',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  color: Colors.grey[600],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Icon(Icons.circle, size: 4.sp, color: Colors.grey[400]),
              ),
              Text(
                '${listing.currency ?? '\$'}${listing.price ?? 0}/${listing.duration ?? 'hr'}',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 16.sp,
                color: Colors.grey[400],
              ),
              SizedBox(width: 4.w),
              Text(
                '189 views', // Not in model yet
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 16.w),
              GestureDetector(
                onTap: () {
                  context.read<BottomNavController>().setIndex(0);
                },
                child: Text(
                  '8 bookings', // Not in model yet
                  style: TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    color: const Color(0xFF636AFF),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildListingButton(
                  icon: Icons.visibility_outlined,
                  label: 'View',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProviderListingDetailsScreen(
                          listingId: listing.sId ?? '',
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: _buildListingButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onTap: () async {
                    // We need full details to edit, so we fetch it first
                    final success = await context
                        .read<MyListingController>()
                        .getSingleListing(listing.sId ?? '');

                    if (success && mounted) {
                      final fullListing = context
                          .read<MyListingController>()
                          .singleListingData;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProviderCreateListingScreen(
                            existingListing: fullListing,
                          ),
                        ),
                      ).then((value) {
                        if (value == true) {
                          context.read<MyListingController>().getMyListings();
                        }
                      });
                    }
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 1,
                child: _buildListingButton(
                  icon: Icons.delete_outline,
                  label: '',
                  isDelete: true,
                  onTap: () {
                    _showDeleteConfirmationDialog(context, listing.sId ?? '');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListingButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDelete = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15.sp, color: Colors.black87),
            if (label.isNotEmpty) ...[
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp.clamp(12, 13),
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(MyListingController controller) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Statistics',
            style: TextStyle(
              fontSize: AppTypography.h2,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Total', controller.totalListings.toString()),
              _buildStatItem('Active', controller.activeListings.toString()),
              _buildStatItem('Drafts', controller.draftListings.toString()),
              _buildStatItem('Past', controller.pastListings.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.bodyMedium,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: AppTypography.h2,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String listingId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cnfermation pop up',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 20.sp),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              Text(
                'Are you want to Decline This',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 25.h),
              const Divider(height: 1),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Yes Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context); // Close dialog

                        // Show loading or just call API
                        final success = await context
                            .read<ServiceController>()
                            .deleteService(listingId);

                        if (success && mounted) {
                          CustomSnackBar.show(
                            context: context,
                            message: "Service deleted successfully",
                          );
                          context
                              .read<MyListingController>()
                              .getMyListings(); // Refresh list
                        } else if (mounted) {
                          CustomSnackBar.show(
                            context: context,
                            message:
                                context
                                    .read<ServiceController>()
                                    .errorMessage ??
                                "Delete failed",
                            isError: true,
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1FFF3),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFFB9F6C0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check,
                              size: 16.sp,
                              color: const Color(0xFF2E7D32),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Yes',
                              style: TextStyle(
                                color: const Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  // No Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F1),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFFFFCDD2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.close,
                              size: 16.sp,
                              color: const Color(0xFFC62828),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'No',
                              style: TextStyle(
                                color: const Color(0xFFC62828),
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
