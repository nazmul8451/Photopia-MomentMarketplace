import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:photopia/controller/provider/calender_availibility_controller.dart';
import 'package:photopia/controller/location_controller.dart';
import 'package:photopia/controller/client/booking_controller.dart';
import 'package:photopia/controller/client/user_profile_controller.dart';
import 'package:photopia/controller/client/payment_controller.dart';
import 'package:photopia/data/models/calender_availibility_model.dart';
import 'package:provider/provider.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic>? service;
  final Map<String, dynamic>? package;
  const BookingConfirmationScreen({super.key, this.service, this.package});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends State<BookingConfirmationScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;
  bool _isSuccess = false;
  bool _isLoadingAvailability = true;

  // Booking Data
  // Booking Data
  DateTime? _selectedDateTime;
  String _selectedTime = '';
  bool _isLoadingSlots = false;
  List<dynamic> _apiAvailableDates = [];
  String _location = '';
  double? _lat;
  double? _lng;
  String? _city;
  String? _country;
  String _specialRequests = '';
  String _paymentMethod = 'Credit/Debit Card';
  String? _createdBookingId; // Track if booking was already created

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _specialRequestsController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  // Availability
  Data? _availabilityData;
  List<DateTime> _availableDates = [];
  List<String> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildAvailableDatesFallback(); // Load fallback dates immediately
      _fetchAvailability();
    });
  }

  Future<void> _fetchAvailability() async {
    setState(() => _isLoadingAvailability = true);

    String? providerId = _getProviderId();
    debugPrint('📅 BookingScreen: Fetching availability for: $providerId');

    if (providerId != null) {
      final controller = context.read<CalenderAvailibilityController>();
      
      try {
        // Run both calls in parallel for speed
        final results = await Future.wait([
          controller.getAvailabilitySettings(providerId: providerId),
          controller.getMonthCalendar(providerId, DateTime.now().month, DateTime.now().year),
        ]);

        final calendarData = results[1] as List<dynamic>;

        if (mounted) {
          setState(() {
            _apiAvailableDates = calendarData;
            _buildAvailableDatesFromApi();
          });
        }
      } catch (e) {
        debugPrint('❌ Error fetching availability: $e');
        _buildAvailableDatesFallback();
      }
    } else {
      _buildAvailableDatesFallback();
    }
    if (mounted) setState(() => _isLoadingAvailability = false);
  }

  String? _getProviderId() {
    if (widget.service?['providerId'] is Map) {
      return widget.service!['providerId']['_id']?.toString() ??
          widget.service!['providerId']['id']?.toString();
    }
    return widget.service?['providerId']?.toString() ??
        widget.service?['provider']?['_id']?.toString() ??
        widget.service?['provider']?['id']?.toString();
  }

  void _buildAvailableDatesFromApi() {
    final List<DateTime> dates = [];
    for (var item in _apiAvailableDates) {
      final dateStr = item['date']?.toString();
      final isAvailable = item['isAvailable'] == true;
      if (dateStr != null && isAvailable) {
        final parsedDate = DateTime.tryParse(dateStr);
        if (parsedDate != null) {
          // Only show future/today dates
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          if (parsedDate.isAfter(today.subtract(const Duration(seconds: 1))) ) {
            dates.add(parsedDate);
          }
        }
      }
    }
    setState(() => _availableDates = dates);
  }

  void _buildAvailableDatesFallback() {
    final List<DateTime> dates = [];
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = DateTime(now.year, now.month, now.day + i);
      dates.add(date);
    }
    setState(() => _availableDates = dates);
  }


  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDateTime = date;
      _selectedTime = '';
    });
    _fetchTimeSlotsFromApi(date);
  }

  Future<void> _fetchTimeSlotsFromApi(DateTime date) async {
    setState(() => _isLoadingSlots = true);
    
    final providerId = _getProviderId();
    if (providerId != null) {
      final controller = context.read<CalenderAvailibilityController>();
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      
      final slots = await controller.getTimeSlots(
        providerId, 
        dateStr, 
        _packageDurationInMinutes
      );

      if (mounted) {
        setState(() {
          _timeSlots = slots;
          _isLoadingSlots = false;
        });
      }
    } else {
      _buildTimeSlotsForDate(date); // Fallback to local logic
      if (mounted) setState(() => _isLoadingSlots = false);
    }
  }

  int get _packageDurationInMinutes {
    final durationStr = (widget.package?['duration'] ?? widget.service?['duration'] ?? '')
        .toString()
        .toLowerCase();
    if (durationStr.contains('4 hour')) return 240;
    if (durationStr.contains('8 hour')) return 480;
    if (durationStr.contains('full day')) return 600;
    
    // Check if it's just a number of hours
    final int? hours = int.tryParse(durationStr.split(' ')[0]);
    if (hours != null) return hours * 60;
    
    return 60; // Default to 1 hour
  }

  void _buildTimeSlotsForDate(DateTime date) {
    String startStr = '09:00';
    String endStr = '18:00';

    // Check custom date override first
    if (_availabilityData?.customDates != null) {
      for (var cd in _availabilityData!.customDates!) {
        if (cd.date != null && cd.type == 'available') {
          final exDate = DateTime.tryParse(cd.date!);
          if (exDate != null &&
              exDate.year == date.year &&
              exDate.month == date.month &&
              exDate.day == date.day) {
            startStr = cd.start ?? startStr;
            endStr = cd.end ?? endStr;
          }
        }
      }
    }

    // Otherwise use the weekly schedule
    Monday? daySchedule;
    switch (date.weekday) {
      case DateTime.monday:
        daySchedule = _availabilityData?.defaultSchedule?.monday;
        break;
      case DateTime.tuesday:
        daySchedule = _availabilityData?.defaultSchedule?.tuesday;
        break;
      case DateTime.wednesday:
        daySchedule = _availabilityData?.defaultSchedule?.wednesday;
        break;
      case DateTime.thursday:
        daySchedule = _availabilityData?.defaultSchedule?.thursday;
        break;
      case DateTime.friday:
        daySchedule = _availabilityData?.defaultSchedule?.friday;
        break;
      case DateTime.saturday:
        daySchedule = _availabilityData?.defaultSchedule?.saturday;
        break;
      case DateTime.sunday:
        daySchedule = _availabilityData?.defaultSchedule?.sunday;
        break;
    }
    if (daySchedule != null) {
      startStr = daySchedule.start ?? startStr;
      endStr = daySchedule.end ?? endStr;
    }

    final slots = <String>[];
    int startHour = int.tryParse(startStr.split(':')[0]) ?? 9;
    final endHour = int.tryParse(endStr.split(':')[0]) ?? 18;
    while (startHour < endHour) {
      slots.add('${startHour.toString().padLeft(2, '0')}:00');
      startHour++;
    }
    setState(() => _timeSlots = slots);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (!_isSuccess) _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _pageIndex = index;
                    if (index == 6) _isSuccess = true;
                  });
                },
                children: [
                  _buildStep1TimeSlots(),
                  _buildStep1FromTo(),
                  _buildStep1FullDay(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildSuccessStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get _currentStep {
    if (_pageIndex < 3) return 0;
    if (_pageIndex == 3) return 1;
    if (_pageIndex == 4) return 2;
    if (_pageIndex == 5) return 3;
    return 4;
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.arrow_back, size: 24.sp, color: Colors.black),
                onPressed: () {
                  if (_pageIndex > 0) {
                    int prevIndex = _pageIndex - 1;
                    if (_pageIndex == 3) prevIndex = 0;
                    _pageController.animateToPage(
                      prevIndex,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              Text(
                'Step ${_currentStep + 1} of 4',
                style: TextStyle(
                  fontSize: 14.sp.clamp(14, 16),
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  height: 4.h,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? Colors.black
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2).r,
                  ),
                ),
              );
            }),
          ),
          Divider(color: Colors.grey.withOpacity(0.1)),
          if (_isLoadingAvailability)
            LinearProgressIndicator(
              backgroundColor: Colors.grey.shade100,
              color: Colors.black,
              minHeight: 2,
            ),
        ],
      ),
    );
  }

  // ─── Step 1 Variants ──────────────────────────────────────────────────────

  Widget _buildStep1TimeSlots() {
    return _buildStep1Scaffold(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStep1Tabs(),
          SizedBox(height: 25.h),
          Text('Available Dates',
              style: TextStyle(
                  fontSize: 14.sp.clamp(14, 16),
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 15.h),
          (_isLoadingAvailability && _availableDates.isEmpty)
              ? SizedBox(
                  height: 180.h,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                )
              : _buildDateGrid(),
          SizedBox(height: 30.h),
          // Only show time slots when a date has been selected
          if (_selectedDateTime != null) ...[
            Text('Time Slot',
                style: TextStyle(
                    fontSize: 14.sp.clamp(14, 16),
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 15.h),
            _isLoadingSlots 
              ? SizedBox(
                  height: 100.h,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                )
              : _buildTimeSlotGrid(),
          ],
        ],
      ),
    );
  }

  Widget _buildStep1FromTo() {
    return _buildStep1Scaffold(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStep1Tabs(),
          SizedBox(height: 25.h),
          Text('Available Dates',
              style: TextStyle(
                  fontSize: 14.sp.clamp(14, 16),
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 15.h),
          (_isLoadingAvailability && _availableDates.isEmpty)
              ? SizedBox(
                  height: 180.h,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                )
              : _buildDateGrid(),
          SizedBox(height: 30.h),
          if (_selectedDateTime != null) _buildTimeRangeInputs(),
        ],
      ),
    );
  }

  Widget _buildStep1FullDay() {
    return _buildStep1Scaffold(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStep1Tabs(),
          SizedBox(height: 25.h),
          Text('Available Dates',
              style: TextStyle(
                  fontSize: 14.sp.clamp(14, 16),
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 15.h),
          (_isLoadingAvailability && _availableDates.isEmpty)
              ? SizedBox(
                  height: 180.h,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                )
              : _buildDateGrid(),
        ],
      ),
    );
  }

  Widget _buildStep1Scaffold(Widget content) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Date & Time',
              style: TextStyle(
                  fontSize: 16.sp.clamp(16, 18),
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text('Choose your preferred date and time slot',
              style: TextStyle(
                  fontSize: 13.sp.clamp(13, 14), color: Colors.grey)),
          SizedBox(height: 25.h),
          if (!_isLoadingAvailability && _availabilityData == null)
            // Padding(
            //   padding: EdgeInsets.only(bottom: 15.h),
            //   child: Container(
            //     padding: EdgeInsets.all(12.w),
            //     decoration: BoxDecoration(
            //       color: Colors.red.shade50,
            //       borderRadius: BorderRadius.circular(8.r),
            //       border: Border.all(color: Colors.red.shade100),
            //     ),
            //     child: Row(
            //       children: [
            //         Icon(Icons.info_outline, color: Colors.red, size: 20.sp),
            //         // SizedBox(width: 10.w),
            //         // Expanded(
            //         //   child: Text(
            //         //     "This provider hasn't set their availability schedule yet.",
            //         //     style: TextStyle(
            //         //         color: Colors.red.shade800, fontSize: 13.sp),
            //         //   ),
            //         // ),
            //       ],
            //     ),
            //   ),
            // ),
          content,
          SizedBox(height: 30.h),
          _buildBottomButton(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildStep1Tabs() {
    final tabs = ['Time Slots', 'From To', 'Full Day'];
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12).r,
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _pageIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _pageController.animateToPage(index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(10).r,
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontSize: 13.sp.clamp(13, 14),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Date Grid (Dynamic) ──────────────────────────────────────────────────

  Widget _buildDateGrid() {
    if (_availableDates.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Text(
            'No available dates found.',
            style: TextStyle(color: Colors.grey, fontSize: 13.sp),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 1.5,
      ),
      itemCount: _availableDates.length,
      itemBuilder: (context, index) {
        final date = _availableDates[index];
        final isSelected = _selectedDateTime != null &&
            _selectedDateTime!.year == date.year &&
            _selectedDateTime!.month == date.month &&
            _selectedDateTime!.day == date.day;

        return GestureDetector(
          onTap: () => _onDateSelected(date),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10).r,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade200,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('EEE').format(date), // Mon, Tue...
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  DateFormat('MMM dd').format(date), // Jun 17
                  style: TextStyle(
                    fontSize: 12.sp.clamp(12, 13),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Time Slot Grid (Dynamic) ─────────────────────────────────────────────

  Widget _buildTimeSlotGrid() {
    if (_timeSlots.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Text('No time slots available.',
              style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
        ),
      );
    }

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: _timeSlots.map((time) {
        final isSelected = _selectedTime == time;
        return GestureDetector(
          onTap: () => setState(() => _selectedTime = time),
          child: Container(
            width: 80.w,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8).r,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade200,
              ),
            ),
            child: Center(
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 12.sp.clamp(12, 13),
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeRangeInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Time Range',
            style: TextStyle(
                fontSize: 14.sp.clamp(14, 16),
                fontWeight: FontWeight.bold)),
        SizedBox(height: 15.h),
        _buildInputLabel('From'),
        _buildTimeTextField('10:00'),
        SizedBox(height: 15.h),
        _buildInputLabel('To'),
        _buildTimeTextField('18:00'),
      ],
    );
  }

  // ─── Steps 2-4 ────────────────────────────────────────────────────────────

  Widget _buildStep2() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Location Details',
                      style: TextStyle(
                          fontSize: 16.sp.clamp(16, 18),
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Text('Where should the session take place?',
                      style: TextStyle(
                          fontSize: 13.sp.clamp(13, 14), color: Colors.grey)),
                ],
              ),
              Consumer<LocationController>(
                builder: (context, locationCtrl, child) {
                  return IconButton(
                    onPressed: () async {
                      await locationCtrl.determinePosition();
                      if (locationCtrl.currentAddress != "Error getting location" &&
                          !locationCtrl.currentAddress.contains("denied")) {
                        setState(() {
                          _location = locationCtrl.currentAddress;
                          _locationController.text = _location;
                          _lat = locationCtrl.latitude;
                          _lng = locationCtrl.longitude;
                          _city = locationCtrl.city;
                          _country = locationCtrl.country;
                        });
                      }
                    },
                    icon: locationCtrl.isLoading
                        ? SizedBox(
                            width: 20.sp,
                            height: 20.sp,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : Icon(Icons.my_location_outlined, color: Colors.black, size: 28.sp),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 25.h),
          _buildInputLabel('Location Address'),
          _buildTextField(
            controller: _locationController,
            hint: 'Enter or detect your location',
            icon: Icons.location_on_outlined,
            onChanged: (val) {
              setState(() {
                _location = val;
                // Clear auto-detected coords if user types manually to prevent mismatch
                _lat = null;
                _lng = null;
                _city = null;
                _country = null;
              });
            },
          ),
          SizedBox(height: 10.h),
          Consumer<LocationController>(
             builder: (context, locationCtrl, _) {
               if (locationCtrl.currentAddress.contains("Off") || locationCtrl.currentAddress.contains("denied")) {
                 return Row(
                   children: [
                     Icon(Icons.info_outline, size: 14.sp, color: Colors.orange),
                     SizedBox(width: 5.w),
                     Expanded(
                       child: Text(
                         "Tip: ${locationCtrl.currentAddress}. You can also type manually.",
                         style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                       ),
                     ),
                   ],
                 );
               }
               return const SizedBox.shrink();
             },
          ),
          SizedBox(height: 25.h),
          _buildInputLabel('Special Requests (Optional)'),
          _buildTextField(
            controller: _specialRequestsController,
            hint: 'Any specific requirements or notes for the photographer',
            maxLines: 5,
            onChanged: (val) => setState(() => _specialRequests = val),
          ),
          SizedBox(height: 40.h),
          _buildBottomButton(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    final dateStr = _selectedDateTime != null
        ? DateFormat('EEEE, MMMM d, y').format(_selectedDateTime!)
        : 'No date selected';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Booking',
              style: TextStyle(
                  fontSize: 16.sp.clamp(16, 18),
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text('Please confirm your booking details',
              style: TextStyle(
                  fontSize: 13.sp.clamp(13, 14), color: Colors.grey)),
          SizedBox(height: 25.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16).r,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReviewItem('Service',
                    widget.service?['title'] ?? 'Photography Session'),
                if (widget.package != null)
                  _buildReviewItem('Package', widget.package!['name'] ?? 'Custom'),
                _buildReviewItem('Provider',
                    widget.service?['providerId']?['name']?.toString() ?? 
                    widget.service?['provider']?['name']?.toString() ??
                    widget.service?['subtitle'] ?? 'Professional'),
                const Divider(),
                _buildReviewIconItem(Icons.calendar_today_outlined, dateStr),
                if (_selectedTime.isNotEmpty)
                  _buildReviewIconItem(Icons.access_time, _selectedTime),
                _buildReviewIconItem(Icons.location_on_outlined,
                    _location.isEmpty ? 'Not specified' : _location),
                if (_specialRequests.isNotEmpty) ...[
                  const Divider(),
                  _buildReviewItem('Special Requests', _specialRequests),
                ],
                const Divider(),
                _buildReviewItem('Price', 
                    '${widget.package?['currency'] ?? widget.service?['currency'] ?? '€'}${_packagePrice.toStringAsFixed(2)}',
                    isBold: true),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          _buildBottomButton(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  double get _packagePrice {
    final priceStr = (widget.package?['price'] ?? widget.service?['price'] ?? '0')
        .toString()
        .replaceAll(',', '');
    return double.tryParse(priceStr) ?? 0;
  }

  double get _serviceFeeAmount {
    return _packagePrice * 0.03; // 3% fee
  }

  double get _totalBookingAmount {
    return _packagePrice + _serviceFeeAmount;
  }

  Widget _buildStep4() {
    final currency = widget.package?['currency'] ?? widget.service?['currency'] ?? '€';
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment',
              style: TextStyle(
                  fontSize: 16.sp.clamp(16, 18),
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text('Complete your booking with payment',
              style: TextStyle(
                  fontSize: 13.sp.clamp(13, 14), color: Colors.grey)),
          SizedBox(height: 25.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16).r,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildPriceRow('Package Total', '$currency${_packagePrice.toStringAsFixed(2)}'),
                _buildPriceRow('Service Fee (3%)', '$currency${_serviceFeeAmount.toStringAsFixed(2)}'),
                const Divider(),
                _buildPriceRow('Total', '$currency${_totalBookingAmount.toStringAsFixed(2)}', isBold: true),
              ],
            ),
          ),
          SizedBox(height: 25.h),
          Text('Payment Method',
              style: TextStyle(
                  fontSize: 14.sp.clamp(14, 16),
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 15.h),
          _buildPaymentOption(
              'Credit/Debit Card', 'Visa, Mastercard, Amex',
              Icons.credit_card_outlined),
          SizedBox(height: 12.h),
          _buildPaymentOption('PayPal', 'Pay with PayPal balance',
              Icons.account_balance_wallet_outlined),
          SizedBox(height: 40.h),
          _buildBottomButton(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Padding(
      padding: EdgeInsets.all(30.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check,
                color: const Color(0xFF4CAF50), size: 40.sp),
          ),
          SizedBox(height: 30.h),
          Text(
            'Booking Confirmed!',
            style: TextStyle(
                fontSize: 18.sp.clamp(18, 22),
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15.h),
          Text(
            "Your session has been successfully booked. You'll receive a confirmation email shortly.",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.sp.clamp(13, 14),
                color: Colors.grey,
                height: 1.5),
          ),
          SizedBox(height: 50.h),
          GestureDetector(
            onTap: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            child: Container(
              width: double.infinity,
              height: 55.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(12).r,
              ),
              child: Center(
                child: Text(
                  'Go to Home',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp.clamp(16, 18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBooking() async {
    // Sync location with controller in case onChanged didn't fire for some edge case
    _location = _locationController.text;
    _specialRequests = _specialRequestsController.text;

    final userProfile = context.read<UserProfileController>().userProfile;
    if (userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to continue')),
      );
      return;
    }

    final providerId = widget.service?['providerId'] is Map
        ? widget.service!['providerId']['_id']?.toString()
        : widget.service?['providerId']?.toString();

    final serviceId = widget.service?['_id'] ?? widget.service?['id'];

    if (providerId == null ||
        serviceId == null ||
        _selectedDateTime == null ||
        _selectedTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing booking details')),
      );
      return;
    }

    if (_location.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a location address')),
      );
      _pageController.animateToPage(
        3, // Move back to Step 2 (Location Details)
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Format date for API (YYYY-MM-DDT00:00:00.000Z)
    final String formattedDate =
        "${DateFormat('yyyy-MM-dd').format(_selectedDateTime!)}T00:00:00.000Z";

    // Calculate endTime based on package or service duration
    String endTime = "18:00";
    if (_selectedTime.isNotEmpty) {
      try {
        final durationStr = (widget.package?['duration'] ?? widget.service?['duration'] ?? "1 hour")
            .toString()
            .toLowerCase();
        final int durationHours = int.tryParse(durationStr.split(' ')[0]) ?? 1;
        final int startHour = int.tryParse(_selectedTime.split(':')[0]) ?? 9;
        endTime = "${(startHour + durationHours).toString().padLeft(2, '0')}:00";
      } catch (e) {
        debugPrint("Error calculating endTime: $e");
      }
    }

    // 1. Create Booking only if not already created
    String? bookingId = _createdBookingId;
    
    if (bookingId == null) {
      bookingId = await context.read<BookingController>().createBooking(
            providerId: providerId,
            serviceId: serviceId.toString(),
            bookingDate: formattedDate,
            startTime: _selectedTime,
            endTime: endTime,
            address: _location,
            city: _city ?? "Dhaka",
            country: _country ?? "Bangladesh",
            lat: _lat ?? 23.8103,
            lng: _lng ?? 90.4125,
            clientName: userProfile.fullName,
            clientEmail: userProfile.email,
            clientPhone: userProfile.phone,
            eventType: "Photography Session",
            specialRequests: _specialRequests,
            notes: _specialRequests,
          );
      
      if (bookingId != null) {
        _createdBookingId = bookingId;
      }
    }

    if (bookingId != null && mounted) {
      // ─── Payment Step ─────────────────────────────────────────────────────
      final paymentCtrl = context.read<PaymentController>();
      
      final bool initialized = await paymentCtrl.initPaymentSheet(
        bookingId: bookingId, 
        amount: _totalBookingAmount, 
        currency: widget.package?['currency'] ?? widget.service?['currency'] ?? 'EUR',
      );

      if (initialized && mounted) {
        final bool paymentSuccess = await paymentCtrl.presentPaymentSheet();
        
        if (paymentSuccess && mounted) {
          // ✅ Payment successful — move to success screen
          debugPrint('🎉 Booking payment successful, order is now pending provider approval!');

          if (mounted) {
            _pageController.animateToPage(
              6,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        } else if (mounted && paymentCtrl.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(paymentCtrl.errorMessage!)),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(paymentCtrl.errorMessage ?? 'Payment initialization failed')),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(context.read<BookingController>().errorMessage ??
                'Booking failed')),
      );
    }
  }

  Widget _buildBottomButton() {
    return Consumer<BookingController>(
      builder: (context, bookingCtrl, child) {
        return GestureDetector(
          onTap: () {
            if (bookingCtrl.isLoading) return;

            if (_pageIndex < 5) {
              // 1. Validation for Step 1 (Date & Time)
              if (_pageIndex < 3) {
                if (_selectedDateTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a date first')),
                  );
                  return;
                }
                // If in "Time Slots" tab, must select a time
                if (_pageIndex == 0 && _selectedTime.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a time slot')),
                  );
                  return;
                }
              }

              // 2. Validation for Step 2 (Location)
              if (_pageIndex == 3 && _location.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a location address')),
                );
                return;
              }

              int nextPageIndex = _pageIndex + 1;
              if (_pageIndex < 3) nextPageIndex = 3;
              _pageController.animateToPage(
                nextPageIndex,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            } else if (_pageIndex == 5) {
              // Final review step -> call API
              _handleBooking();
            }
          },
          child: Container(
            width: double.infinity,
            height: 55.h,
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              borderRadius: BorderRadius.circular(12).r,
            ),
            child: Center(
              child: bookingCtrl.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _pageIndex == 5 ? 'Pay & Confirm' : 'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp.clamp(16, 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 13.sp.clamp(13, 14),
            color: Colors.black87,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField(
      {required String hint,
      IconData? icon,
      int maxLines = 1,
      TextEditingController? controller,
      Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(fontSize: 13.sp.clamp(13, 14), color: Colors.grey.shade400),
        prefixIcon:
            icon != null ? Icon(icon, size: 20.sp, color: Colors.grey) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(16.w),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10).r,
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10).r,
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildTimeTextField(String time) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10).r,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(time,
          style: TextStyle(fontSize: 14.sp.clamp(14, 15))),
    );
  }

  Widget _buildReviewItem(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11.sp.clamp(11, 12), color: Colors.grey)),
          SizedBox(height: 4.h),
          Text(value,
              style: TextStyle(
                  fontSize: 14.sp.clamp(14, 16),
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildReviewIconItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp.clamp(18, 20), color: Colors.grey),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13.sp.clamp(13, 14),
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp.clamp(13, 14),
              color: isBold ? Colors.black : Colors.grey,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp.clamp(13, 15),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      String title, String subtitle, IconData icon) {
    final isSelected = _paymentMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = title),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12).r,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8).r,
              ),
              child: Icon(icon, size: 20.sp, color: Colors.black),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14.sp.clamp(14, 16),
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11.sp.clamp(11, 12),
                          color: Colors.grey)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check, size: 20.sp, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
