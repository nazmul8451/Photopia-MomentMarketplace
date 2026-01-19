import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProviderOverviewScreen extends StatefulWidget {
  const ProviderOverviewScreen({super.key});

  @override
  State<ProviderOverviewScreen> createState() => _ProviderOverviewScreenState();
}

class _ProviderOverviewScreenState extends State<ProviderOverviewScreen> {
  String _selectedStatus = 'Active';

  final List<Map<String, dynamic>> _allListings = [
    {
      'title': 'Professional Portrait Photography',
      'category': 'Photography',
      'rate': '\$150/hr',
      'status': 'Active',
      'views': 189,
      'bookings': 8,
    },
    {
      'title': 'Event Photography',
      'category': 'Photography',
      'rate': '\$200/hr',
      'status': 'Active',
      'views': 189,
      'bookings': 8,
    },
    {
      'title': 'Product Photography',
      'category': 'Photography',
      'rate': '\$120/hr',
      'status': 'Drafts',
      'views': 45,
      'bookings': 0,
    },
    {
      'title': 'Fashion Photography',
      'category': 'Photography',
      'rate': '\$180/hr',
      'status': 'Past',
      'views': 250,
      'bookings': 12,
    },
  ];

  List<Map<String, dynamic>> get _filteredListings =>
      _allListings.where((listing) => listing['status'] == _selectedStatus).toList();

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
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.add, size: 18.sp, color: Colors.white),
                label: Text(
                  'Create',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
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
            ..._filteredListings.map((listing) => _buildListingCard(listing)),
            SizedBox(height: 20.h),
            // Overall Statistics
            _buildStatisticsSection(),
            SizedBox(height: 30.h),
          ],
        ),
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
            color: isSelected ? const Color(0xFF1F1F1F) : const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> listing) {
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
                  listing['title'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  listing['status'],
                  style: TextStyle(
                    fontSize: 11.sp,
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
                listing['category'],
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Icon(Icons.circle, size: 4.sp, color: Colors.grey[400]),
              ),
              Text(
                listing['rate'],
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.visibility_outlined, size: 16.sp, color: Colors.grey[400]),
              SizedBox(width: 4.w),
              Text(
                '${listing['views']} views',
                style: TextStyle(fontSize: 13.sp, color: Colors.black87),
              ),
              SizedBox(width: 16.w),
              Text(
                '${listing['bookings']} bookings',
                style: TextStyle(fontSize: 13.sp, color: const Color(0xFF636AFF)),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(flex:2,
                child: _buildListingButton(
                  icon: Icons.visibility_outlined,
                  label: 'View',
                  onTap: () {},
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: _buildListingButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onTap: () {},
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 1,
                child: _buildListingButton(
                  icon: Icons.delete_outline,
                  label: '',
                  isDelete: true,
                  onTap: () {},
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp.clamp(12,13),
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
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
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Total', _allListings.length.toString()),
              _buildStatItem('Active', _allListings.where((l) => l['status'] == 'Active').length.toString()),
              _buildStatItem('Drafts', _allListings.where((l) => l['status'] == 'Drafts').length.toString()),
              _buildStatItem('Past', _allListings.where((l) => l['status'] == 'Past').length.toString()),
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
            fontSize: 13.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
