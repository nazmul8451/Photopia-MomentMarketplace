import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/provider_profile_screen.dart';

class ProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;

  const ProviderCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundImage: NetworkImage(provider['avatar'] ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200'),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          provider['name'] ?? 'Emma Wilson',
                          style: TextStyle(
                            fontSize: 14.sp.clamp(14, 16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (provider['isPremium'] ?? false)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20).r,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.stars, color: Colors.orange, size: 10.sp),
                                SizedBox(width: 2.w),
                                Text(
                                  'Premium',
                                  style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Text(
                      provider['category'] ?? 'Wedding & Event Photography',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          provider['location'] ?? 'Barcelona, Spain',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          '${provider['rating'] ?? 4.9} (${provider['reviews'] ?? 127})',
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Response: ${provider['responseTime'] ?? '95%'}',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: const BorderSide(color: Color(0xFFE9ECEF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8).r),
                    backgroundColor: const Color(0xFF1A1A1A),
                  ),
                  child: Text('Message', style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProviderProfileScreen(provider: provider),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: const BorderSide(color: Colors.transparent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8).r),
                    backgroundColor: const Color(0xFFF1F3F5),
                  ),
                  child: Text('View Profile', style: TextStyle(color: Colors.black, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
