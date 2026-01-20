import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/provider/widgets/provider_custom_bottom_nav_bar.dart';
import 'package:photopia/features/provider/screen/BottomNavigationBar/bottom_navigation_screen.dart';

class ProviderCreateListingScreen extends StatefulWidget {
  const ProviderCreateListingScreen({super.key});

  @override
  State<ProviderCreateListingScreen> createState() => _ProviderCreateListingScreenState();
}

class _ProviderCreateListingScreenState extends State<ProviderCreateListingScreen> {
  String _selectedServiceType = 'Photography';
  String _selectedPricingModel = 'By Hour';
  double _serviceRadius = 25.0;
  bool _acceptOutsideRadius = false;
  final List<String> _equipment = [];
  final TextEditingController _equipmentController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _weekendRateController = TextEditingController();
  final TextEditingController _basicPackageController = TextEditingController();
  final TextEditingController _standardPackageController = TextEditingController();
  final TextEditingController _premiumPackageController = TextEditingController();

  @override
  void dispose() {
    _equipmentController.dispose();
    _hourlyRateController.dispose();
    _weekendRateController.dispose();
    _basicPackageController.dispose();
    _standardPackageController.dispose();
    _premiumPackageController.dispose();
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
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Listing',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTypography.h1,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Listing Title'),
            _buildTextField(hintText: 'Event Photography'),
            SizedBox(height: 20.h),
            
            _buildLabel('Select the category that fits your services best:'),
            _buildDropdown(['Photography', 'Videography', 'Video Editing']),
            SizedBox(height: 20.h),
            
            _buildLabel('Service Type'),
            _buildRadioOption('Photography'),
            _buildRadioOption('Videography'),
            _buildRadioOption('Video Editing'),
            SizedBox(height: 20.h),
            
            _buildLabel('Pricing Model'),
            _buildPricingToggle(),
            SizedBox(height: 20.h),
            
            if (_selectedPricingModel == 'By Service') ...[
              _buildLabel('Basic Package (\$)'),
              _buildTextField(hintText: '500', controller: _basicPackageController),
              SizedBox(height: 20.h),
              
              _buildLabel('Standard Package (\$)'),
              _buildTextField(hintText: '1200', controller: _standardPackageController),
              SizedBox(height: 20.h),
              
              _buildLabel('Premium Package (\$)'),
              _buildTextField(hintText: '2500', controller: _premiumPackageController),
              SizedBox(height: 20.h),
            ] else ...[
              _buildLabel('${_selectedPricingModel == 'By Day' ? 'Daily' : 'Weekday Hourly'} Rate (\$)'),
              _buildTextField(hintText: _selectedPricingModel == 'By Day' ? '800' : '150', controller: _hourlyRateController),
              SizedBox(height: 20.h),
              
              _buildLabel('${_selectedPricingModel == 'By Day' ? 'Weekend Daily' : 'Weekend Hourly'} Rate (\$)'),
              _buildTextField(hintText: _selectedPricingModel == 'By Day' ? '1000' : '180', controller: _weekendRateController),
              SizedBox(height: 20.h),
            ],
            
            _buildLabel('Description'),
            _buildTextField(hintText: 'Describe your service...', maxLines: 4),
            SizedBox(height: 20.h),
            
            _buildLabel('Duration (Optional)'),
            _buildTextField(hintText: '2-4 hours'),
            SizedBox(height: 20.h),
            
            _buildLabel('Location'),
            _buildTextField(hintText: 'New York, NY'),
            SizedBox(height: 20.h),
            
            _buildLabel('Service Radius: ${_serviceRadius.toInt()} miles'),
            _buildRadiusSlider(),
            SizedBox(height: 10.h),
            
            _buildAcceptOutsideRadiusToggle(),
            SizedBox(height: 20.h),
            
            _buildLabel('Equipment'),
            _buildEquipmentInput(),
            if (_equipment.isNotEmpty) _buildEquipmentList(),
            SizedBox(height: 20.h),
            
            _buildLabel('Photos'),
            _buildPhotoUploadArea(),
            SizedBox(height: 30.h),
            
            _buildFooterButtons(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      bottomNavigationBar: null,
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppTypography.bodySmall,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({required String hintText, int maxLines = 1, TextEditingController? controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: AppTypography.bodyLarge),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 24.sp, color: Colors.grey),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(fontSize: AppTypography.bodyLarge)),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    bool isSelected = _selectedServiceType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedServiceType = value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? Colors.black : Colors.grey[400]!),
              ),
              child: isSelected ? Center(
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ) : null,
            ),
            SizedBox(width: 12.w),
            Text(value, style: TextStyle(fontSize: AppTypography.bodyLarge, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingToggle() {
    return Row(
      children: ['By Hour', 'By Day', 'By Service'].map((model) {
        bool isSelected = _selectedPricingModel == model;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPricingModel = model),
            child: Container(
              margin: EdgeInsets.only(right: model == 'By Service' ? 0 : 8.w),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: isSelected ? Colors.black : const Color(0xFFE0E0E0)),
              ),
              child: Text(
                model,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontSize: AppTypography.bodyMedium,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRadiusSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.black,
        inactiveTrackColor: const Color(0xFFF0F0F0),
        thumbColor: Colors.black,
        overlayColor: Colors.black.withOpacity(0.1),
        trackHeight: 4.h,
      ),
      child: Slider(
        min: 0,
        max: 100,
        value: _serviceRadius,
        onChanged: (val) => setState(() => _serviceRadius = val),
      ),
    );
  }

  Widget _buildAcceptOutsideRadiusToggle() {
    return GestureDetector(
      onTap: () => setState(() => _acceptOutsideRadius = !_acceptOutsideRadius),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _acceptOutsideRadius ? Colors.black : Colors.grey[400]!),
            ),
            child: _acceptOutsideRadius ? Center(
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ) : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accept orders from outside location radius',
                  style: TextStyle(fontSize: AppTypography.bodyLarge, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Additional travel fees may apply for bookings outside your service radius',
                  style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentInput() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: TextField(
              controller: _equipmentController,
              decoration: InputDecoration(
                hintText: 'Canon EOS R5',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: AppTypography.bodyLarge),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: () {
            if (_equipmentController.text.isNotEmpty) {
              setState(() {
                _equipment.add(_equipmentController.text);
                _equipmentController.clear();
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              'Add',
              style: TextStyle(color: Colors.white, fontSize: AppTypography.bodyLarge, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentList() {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: _equipment.map((item) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item, style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.black87)),
                SizedBox(width: 4.w),
                GestureDetector(
                  onTap: () => setState(() => _equipment.remove(item)),
                  child: Icon(Icons.close, size: 14.sp, color: Colors.black54),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhotoUploadArea() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: const Color(0xFFE0E0E0), style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_upload_outlined, size: 40.sp, color: Colors.grey[400]),
          SizedBox(height: 12.h),
          Text(
            'Click to upload photos and videos',
            style: TextStyle(fontSize: AppTypography.bodyLarge, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 4.h),
          Text(
            'or drag and drop',
            style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(0, 50.h),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text('Save as Draft', style: TextStyle(color: Colors.black, fontSize: AppTypography.bodyLarge)),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: ElevatedButton(
                onPressed: null, // Disabled until required fields filled
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1D5DB),
                  disabledBackgroundColor: const Color(0xFFD1D5DB),
                  minimumSize: Size(0, 50.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  elevation: 0,
                ),
                child: Text('Publish', style: TextStyle(color: Colors.white, fontSize: AppTypography.bodyLarge)),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Center(
          child: Text(
            'Please complete all required fields to publish',
            style: TextStyle(color: Colors.red[400], fontSize: AppTypography.bodySmall),
          ),
        ),
      ],
    );
  }
}
