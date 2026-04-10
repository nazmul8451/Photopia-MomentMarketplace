import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/features/client/search_filter_screen.dart';

class SearchHeader extends StatefulWidget {
  final Function(Map<String, dynamic>)? onFilterApplied;
  const SearchHeader({super.key, this.onFilterApplied});

  @override
  State<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (widget.onFilterApplied != null) {
        widget.onFilterApplied!({'searchTerm': value});
      }
    });
  }

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
                    controller: _searchController,
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search photographers, services...',
                      hintStyle: TextStyle(
                        color: Colors.grey.withOpacity(0.6),
                        fontSize: 12.sp.clamp(12, 13),
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 12.w, right: 4.w),
                        child: Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 20.sp.clamp(20, 22),
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 35.w,
                        minHeight: 40.h,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (value) {
                      if (widget.onFilterApplied != null) {
                        widget.onFilterApplied!({'searchTerm': value});
                      }
                    },
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
                  onPressed: () async {
                    // Navigate to filter screen and wait for result
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchFilterScreen(),
                      ),
                    );
                    if (result != null && widget.onFilterApplied != null) {
                      // Include the current search term in the filter map
                      result['searchTerm'] = _searchController.text;
                      widget.onFilterApplied!(result);
                    }
                  },
                  icon: Image.asset(
                    'assets/images/filter_icon.png',
                    height: 20.h,
                    width: 20.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }
}
