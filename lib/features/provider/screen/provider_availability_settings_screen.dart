import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:photopia/core/widgets/custom_snacbar.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/provider/calender_availibility_controller.dart';
import 'package:photopia/controller/client/user_profile_controller.dart';
import 'package:photopia/data/models/calender_availibility_model.dart';
import 'package:photopia/controller/provider/service_controller.dart';
import 'package:photopia/controller/provider/provider_profile_controller.dart';

class ProviderAvailabilitySettingsScreen extends StatefulWidget {
  const ProviderAvailabilitySettingsScreen({super.key});

  @override
  State<ProviderAvailabilitySettingsScreen> createState() => _ProviderAvailabilitySettingsScreenState();
}

class _ProviderAvailabilitySettingsScreenState extends State<ProviderAvailabilitySettingsScreen> {
  // Automation Settings State
  String _selectedPricingModel = 'By Hour';
  final TextEditingController _defaultRateController = TextEditingController(text: '100');
  final TextEditingController _weekendRateController = TextEditingController(text: '120');
  bool _isLoading = false;
  Data? _availabilityData;

  // New Advanced Controllers
  final TextEditingController _bufferMinutesController = TextEditingController(text: '15');
  final TextEditingController _advanceNoticeController = TextEditingController(text: '24');
  final TextEditingController _maxBookingsDayController = TextEditingController(text: '3');
  final TextEditingController _maxBookingsWeekController = TextEditingController(text: '10');
  final TextEditingController _autoBlockDurationController = TextEditingController(text: '30');
  bool _autoBlockAfterBooking = true;

  // Granular Schedule State
  final Map<String, Monday> _defaultSchedule = {
    'Monday': Monday(start: '09:00', end: '18:00', isActive: true, maxBookings: 2),
    'Tuesday': Monday(start: '09:00', end: '18:00', isActive: true, maxBookings: 2),
    'Wednesday': Monday(start: '09:00', end: '18:00', isActive: true, maxBookings: 2),
    'Thursday': Monday(start: '09:00', end: '18:00', isActive: true, maxBookings: 2),
    'Friday': Monday(start: '09:00', end: '18:00', isActive: true, maxBookings: 2),
    'Saturday': Monday(start: '10:00', end: '16:00', isActive: true, maxBookings: 1),
    'Sunday': Monday(start: '10:00', end: '16:00', isActive: false, maxBookings: 1),
  };

  List<CustomDates> _customDates = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAvailability();
    });
  }

  Future<void> _fetchAvailability() async {
    setState(() => _isLoading = true);
    final controller = context.read<CalenderAvailibilityController>();

    final profileController = context.read<UserProfileController>();
    if (profileController.userProfile == null) {
      await profileController.getUserProfile();
    }

    final String? providerId = profileController.userProfile?.id;
    debugPrint('🔍 Settings: Fetching availability for ProviderID: $providerId');

    final settingsModel = await controller.getAvailabilitySettings(providerId: providerId);
    
    final serviceController = context.read<ServiceController>();
    if (serviceController.myServices.isEmpty) {
      await serviceController.getMyServices();
    }

    if (mounted && settingsModel != null && settingsModel.data != null) {
      debugPrint('✅ Settings: Data Received, updating UI...');
      setState(() {
        _availabilityData = settingsModel.data;
        _updateUIFromData(_availabilityData!);
      });
    } else {
      debugPrint('⚠️ Settings: No data received or settingsModel is null');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _updateUIFromData(Data data) {
    final schedule = data.defaultSchedule;
    if (schedule != null) {
      _defaultSchedule['Monday'] = schedule.monday ?? _defaultSchedule['Monday']!;
      _defaultSchedule['Tuesday'] = schedule.tuesday ?? _defaultSchedule['Tuesday']!;
      _defaultSchedule['Wednesday'] = schedule.wednesday ?? _defaultSchedule['Wednesday']!;
      _defaultSchedule['Thursday'] = schedule.thursday ?? _defaultSchedule['Thursday']!;
      _defaultSchedule['Friday'] = schedule.friday ?? _defaultSchedule['Friday']!;
      _defaultSchedule['Saturday'] = schedule.saturday ?? _defaultSchedule['Saturday']!;
      _defaultSchedule['Sunday'] = schedule.sunday ?? _defaultSchedule['Sunday']!;
    }

    _bufferMinutesController.text = data.bufferMinutes?.toString() ?? '15';
    _advanceNoticeController.text = data.advanceNoticeHours?.toString() ?? '24';
    _maxBookingsDayController.text = data.maxBookingsPerDay?.toString() ?? '3';
    _maxBookingsWeekController.text = data.maxBookingsPerWeek?.toString() ?? '10';
    _autoBlockDurationController.text = data.autoBlockDuration?.toString() ?? '30';
    _autoBlockAfterBooking = data.autoBlockAfterBooking ?? true;
    _customDates = data.customDates ?? [];

    if (data.pricing != null) {
      final model = data.pricing!.model?.toLowerCase();
      if (model == 'hourly') {
        _selectedPricingModel = 'By Hour';
      } else if (model == 'daily') {
        _selectedPricingModel = 'By Day';
      } else if (model == 'service') {
        _selectedPricingModel = 'By Service';
      } else {
        _selectedPricingModel = data.pricing!.model ?? 'By Hour';
      }

      _defaultRateController.text = data.pricing!.baseRate?.toString() ?? '100';
      _weekendRateController.text = data.pricing!.weekendRate?.toString() ?? '120';
    }
  }

  Future<void> _saveSettings() async {
    final profileController = context.read<UserProfileController>();
    final availabilityController = context.read<CalenderAvailibilityController>();

    String? providerId = profileController.userProfile?.id;
    if (providerId == null || providerId.isEmpty) {
      final providerProfileController = context.read<ProviderProfileController>();
      providerId = providerProfileController.userProfile?.id;
    }

    if (providerId == null || providerId.isEmpty) {
      providerId = _availabilityData?.providerId;
    }

    if (providerId == null || providerId.isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: 'Provider ID not found. Please try refreshing.',
        isError: true,
      );
      return;
    }

    final Data dataToSave = _availabilityData ?? Data();
    dataToSave.providerId = providerId;

    final String pricingModelValue = _selectedPricingModel == 'By Hour'
        ? 'hourly'
        : _selectedPricingModel == 'By Day'
            ? 'daily'
            : 'service';

    dataToSave.pricing = Pricing(
      model: pricingModelValue,
      baseRate: double.tryParse(_defaultRateController.text) ?? 100.0,
      weekendRate: double.tryParse(_weekendRateController.text) ?? 120.0,
    );

    dataToSave.bufferMinutes = int.tryParse(_bufferMinutesController.text) ?? 15;
    dataToSave.advanceNoticeHours = int.tryParse(_advanceNoticeController.text) ?? 24;
    dataToSave.maxBookingsPerDay = int.tryParse(_maxBookingsDayController.text) ?? 3;
    dataToSave.maxBookingsPerWeek = int.tryParse(_maxBookingsWeekController.text) ?? 10;
    dataToSave.autoBlockAfterBooking = _autoBlockAfterBooking;
    dataToSave.autoBlockDuration = int.tryParse(_autoBlockDurationController.text) ?? 30;

    dataToSave.defaultSchedule = DefaultSchedule(
      monday: _defaultSchedule['Monday'],
      tuesday: _defaultSchedule['Tuesday'],
      wednesday: _defaultSchedule['Wednesday'],
      thursday: _defaultSchedule['Thursday'],
      friday: _defaultSchedule['Friday'],
      saturday: _defaultSchedule['Saturday'],
      sunday: _defaultSchedule['Sunday'],
    );

    dataToSave.customDates = _customDates;

    dataToSave.googleCalendarSync ??= GoogleCalendarSync(
      calendarId: "primary",
      syncEnabled: false,
    );

    final success = await availabilityController.updateAvailability(dataToSave);

    if (mounted) {
      CustomSnackBar.show(
        context: context,
        message: success
            ? 'Settings saved successfully!'
            : (availabilityController.errorMessage ?? 'Failed to save settings'),
        isError: !success,
      );
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _defaultRateController.dispose();
    _weekendRateController.dispose();
    _bufferMinutesController.dispose();
    _advanceNoticeController.dispose();
    _maxBookingsDayController.dispose();
    _maxBookingsWeekController.dispose();
    _autoBlockDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Availability Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(width: 10.w),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                children: [
                  /* // Pricing & Rates Card
                  _buildSectionCard(
                    title: 'Pricing & Rates',
                    icon: Icons.payments_outlined,
                    color: const Color(0xFF6366F1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select how you want to bill your clients',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 15.h),
                        Row(
                          children: [
                            _buildPricingOption('By Hour'),
                            SizedBox(width: 10.w),
                            _buildPricingOption('By Day'),
                            SizedBox(width: 10.w),
                            _buildPricingOption('By Service'),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: 'Base Rate (\$)',
                                controller: _defaultRateController,
                              ),
                            ),
                            SizedBox(width: 15.w),
                            Expanded(
                              child: _buildInputField(
                                label: 'Weekend Rate (\$)',
                                controller: _weekendRateController,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25.h), */

                  // Weekly Schedule Card
                  _buildSectionCard(
                    title: 'Weekly Working Hours',
                    icon: Icons.calendar_month_outlined,
                    color: const Color(0xFFF59E0B),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set your standard working hours for each day',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 15.h),
                        _buildDailyScheduleSelector(),
                      ],
                    ),
                  ),
                  SizedBox(height: 25.h),

                  /* // Booking Rules Card
                  _buildSectionCard(
                    title: 'Advanced Booking Rules',
                    icon: Icons.tune_rounded,
                    color: const Color(0xFF10B981),
                    child: _buildAdvancedSettings(),
                  ),
                  SizedBox(height: 25.h), */

                  /* // Exceptions Card
                  _buildSectionCard(
                    title: 'Custom Dates & Exceptions',
                    icon: Icons.event_busy_outlined,
                    color: const Color(0xFFEF4444),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Override your default schedule for specific days',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 15.h),
                        if (_customDates.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Text(
                                'No custom exceptions added yet.',
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: _customDates.map((cd) => _buildCustomDateItem(cd)).toList(),
                          ),
                        SizedBox(height: 15.h),
                        OutlinedButton.icon(
                          onPressed: _addCustomDateException,
                          icon: const Icon(Icons.add_circle_outline, color: Colors.black, size: 20),
                          label: Text(
                            'Add New Exception',
                            style: TextStyle(fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 45.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            side: const BorderSide(color: Colors.black12),
                          ),
                        ),
                      ],
                    ),
                  ), */
                  SizedBox(height: 40.h),
                  
                  // Save Button at bottom
                  ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(double.infinity, 55.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      'Save All Changes',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
    );
  }

  // Replicated helper widgets from ProviderCalendarScreen
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 22.sp),
              ),
              SizedBox(width: 15.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          child,
        ],
      ),
    );
  }

  Widget _buildPricingOption(String label) {
    bool isSelected = _selectedPricingModel == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPricingModel = label),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9F9FB),
            contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyScheduleSelector() {
    return Column(
      children: _defaultSchedule.entries.map((entry) {
        return _buildDayScheduleItem(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildDayScheduleItem(String day, Monday schedule) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: schedule.isActive == true ? Colors.white : const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: schedule.isActive == true ? Colors.black12 : Colors.transparent),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: schedule.isActive,
                onChanged: (val) => setState(() => schedule.isActive = val),
                activeColor: Colors.black,
              ),
              Text(
                day,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: schedule.isActive == true ? Colors.black : Colors.grey,
                ),
              ),
              const Spacer(),
              if (schedule.isActive == true)
                const Text('Working', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))
              else
                const Text('Off Day', style: TextStyle(fontSize: 10, color: Colors.redAccent)),
            ],
          ),
          if (schedule.isActive == true) ...[
            const Divider(),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildTimePickerField('Start', schedule.start ?? '09:00', (time) {
                  setState(() => schedule.start = time);
                }),
                SizedBox(width: 15.w),
                _buildTimePickerField('End', schedule.end ?? '18:00', (time) {
                  setState(() => schedule.end = time);
                }),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jobs/Day', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                      SizedBox(height: 4.h),
                      SizedBox(
                        height: 35.h,
                        child: TextField(
                          onChanged: (val) => schedule.maxBookings = int.tryParse(val) ?? 1,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: schedule.maxBookings?.toString(),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(color: Colors.black12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimePickerField(String label, String value, Function(String) onSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
              hour: int.parse(value.split(':')[0]),
              minute: int.parse(value.split(':')[1]),
            ),
          );
          if (time != null) {
            final formatted = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
            onSelected(formatted);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
            SizedBox(height: 4.h),
            Container(
              height: 35.h,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                  Icon(Icons.access_time, size: 14.sp, color: Colors.black54),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingRow('Buffer Minutes', 'Break between bookings', _bufferMinutesController, Icons.timer_outlined),
        SizedBox(height: 12.h),
        _buildSettingRow('Advance Notice (h)', 'Min time before booking', _advanceNoticeController, Icons.notifications_active_outlined),
        SizedBox(height: 12.h),
        _buildSettingRow('Max Bookings/Day', 'Limit daily bookings', _maxBookingsDayController, Icons.event_available_outlined),
        SizedBox(height: 12.h),
        _buildSettingRow('Max Bookings/Week', 'Limit weekly bookings', _maxBookingsWeekController, Icons.date_range_outlined),
        SizedBox(height: 15.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(10.r)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Auto-block After Booking', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  Text('Block time for prep', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                ],
              ),
              Switch(
                value: _autoBlockAfterBooking,
                onChanged: (val) => setState(() => _autoBlockAfterBooking = val),
                activeColor: Colors.black,
              ),
            ],
          ),
        ),
        if (_autoBlockAfterBooking) ...[
          SizedBox(height: 12.h),
          _buildSettingRow('Auto-block Duration (m)', 'Time to block after each job', _autoBlockDurationController, Icons.block_flipped),
        ],
      ],
    );
  }

  Widget _buildSettingRow(String title, String subtitle, TextEditingController controller, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: const Color(0xFFF1F1F1), borderRadius: BorderRadius.circular(8.r)),
          child: Icon(icon, size: 20.sp, color: Colors.black87),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
              Text(subtitle, style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        SizedBox(
          width: 60.w,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 8.h),
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomDateItem(CustomDates cd) {
    DateTime? date;
    if (cd.date != null) {
      try {
        date = DateTime.parse(cd.date!);
      } catch (e) {
        // ignore
      }
    }
    bool isAvailable = cd.type == 'available';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: const Color(0xFFF9F9F9), borderRadius: BorderRadius.circular(10.r)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date != null ? DateFormat('MMM dd, yyyy').format(date) : 'Unknown Date', 
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              Text(isAvailable ? 'Available: ${cd.start} - ${cd.end}' : 'Unavailable', 
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
            ],
          ),
          IconButton(
            onPressed: () => setState(() => _customDates.remove(cd)),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  void _addCustomDateException() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _customDates.add(CustomDates(
          date: picked.toIso8601String(),
          type: 'unavailable',
          start: "09:00",
          end: "17:00",
        ));
      });
    }
  }
}
