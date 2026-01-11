import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'Search',
           style: TextStyle(
                  fontSize: 20.sp.clamp(20, 22),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
          ),
        ),
        SizedBox(height: 15.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
             Expanded(
                child: Container(
                  height: 40.h.clamp(40, 42),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12).r,
                    border: Border.all(color: Colors.black54.withOpacity(0.3)),
                  ),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: 'Search photographers, services...',
                      hintStyle: TextStyle(
                        color: Colors.grey.withOpacity(0.6),
                        fontSize: 12.sp.clamp(12,13),
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 12.w, right: 8.w),
                        child: Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 20.sp.clamp(20, 22),
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 40.w,
                        minHeight: 40.h,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.h,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                height: 40.h.clamp(40, 42),
                width: 40.h.clamp(40, 42),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12).r,
                  border: Border.all(color: Colors.black54.withOpacity(0.3)),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.tune, color: Colors.black, size: 22.sp.clamp(22, 24)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.h),
        SizedBox(
          height: 35.h,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            scrollDirection: Axis.horizontal,
            children: [
              _buildHashTag('#Wedding'),
              _buildHashTag('#Portrait'),
              _buildHashTag('#Corporate'),
              _buildHashTag('#ProductPhotography'),
            ],
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildHashTag(String tag) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20).r,
      ),
      child: Center(
        child: Text(
          tag,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}
