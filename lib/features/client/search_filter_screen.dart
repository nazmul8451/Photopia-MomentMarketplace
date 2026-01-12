import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final TextEditingController _locationController = TextEditingController(text: 'Barcelona, Spain');
  double _radius = 200;
  final TextEditingController _minBudgetController = TextEditingController(text: '0');
  final TextEditingController _maxBudgetController = TextEditingController(text: '5000');

  final List<String> _serviceTypes = [
    'Photography', 'Videography', 'Wedding', 'Corporate', 
    'Portrait', 'Product', 'Fashion', 'Real Estate', 
    'Event', 'Aerial/Drone'
  ];
  final Set<String> _selectedServices = {'Photography'};

  final List<String> _equipments = [
    'DSLR', 'Mirrorless', 'Drone', '4K Video', 
    'Studio Lighting', 'Smartphone', 'Cinema Camera', 'Gimbal/Stabilizer'
  ];
  final Set<String> _selectedEquipments = {'DSLR'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search Filter',
          style: TextStyle(
            color:  Colors.black, // Light blue color from image
            fontSize: 18.sp.clamp(18, 20),
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
            _buildSectionTitle('Location'),
            SizedBox(height: 10.h),
            _buildTextField(
              controller: _locationController,
              hint: 'Search location...',
              prefixIcon: Icons.location_on_outlined,
            ),
            SizedBox(height: 20.h),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Radius: ${_radius.toInt()} km'),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4.h,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
                activeTrackColor: Colors.black,
                inactiveTrackColor: Colors.grey.shade200,
                thumbColor: Colors.black,
              ),
              child: Slider(
                value: _radius,
                min: 0,
                max: 500,
                onChanged: (value) {
                  setState(() => _radius = value);
                },
              ),
            ),
            SizedBox(height: 20.h),

            _buildSectionTitle('Budget (€)'),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _minBudgetController,
                    hint: 'Min',
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Text('-', style: TextStyle(fontSize: 18.sp, color: Colors.grey)),
                ),
                Expanded(
                  child: _buildTextField(
                    controller: _maxBudgetController,
                    hint: 'Max',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 25.h),

            _buildSectionTitle('Type of Service'),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _serviceTypes.map((service) => _buildFilterChip(
                label: service,
                isSelected: _selectedServices.contains(service),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedServices.add(service);
                    } else {
                      _selectedServices.remove(service);
                    }
                  });
                },
              )).toList(),
            ),
            SizedBox(height: 25.h),

            _buildSectionTitle('Equipment Used'),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _equipments.map((equipment) => _buildFilterChip(
                label: equipment,
                isSelected: _selectedEquipments.contains(equipment),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedEquipments.add(equipment);
                    } else {
                      _selectedEquipments.remove(equipment);
                    }
                  });
                },
              )).toList(),
            ),
            SizedBox(height: 40.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedServices.clear();
                        _selectedEquipments.clear();
                        _radius = 200;
                        _locationController.text = '';
                        _minBudgetController.text = '0';
                        _maxBudgetController.text = '5000';
                      });
                      Navigator.pop(context); // Optional: if "clear all" should also go back
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFE9ECEF),
                      side: BorderSide.none,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10).r,
                      ),
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(color: Colors.black87, fontSize: 16.sp.clamp(16, 18), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply filters logic
                      Navigator.pop(context, {
                        'location': _locationController.text,
                        'radius': _radius,
                        'minBudget': _minBudgetController.text,
                        'maxBudget': _maxBudgetController.text,
                        'services': _selectedServices.toList(),
                        'equipments': _selectedEquipments.toList(),
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10).r,
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp.clamp(16, 18), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10).r,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey, size: 20.sp) : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: Colors.black,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontSize: 13.sp.clamp(13, 15),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10).r,
        side: BorderSide(color: isSelected ? Colors.black : Colors.grey.shade200),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
    );
  }
}
