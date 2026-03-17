import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:photopia/controller/provider/calender_availibility_controller.dart';
import 'package:photopia/data/models/calender_availibility_model.dart';
import 'package:provider/provider.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic>? service;
  const BookingConfirmationScreen({super.key, this.service});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends State<BookingConfirmationScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;
  bool _isSuccess = false;
  bool _isLoadingAvailability = false;

  // Booking Data
  DateTime? _selectedDateTime;
  String _selectedTime = '';
  String _location = '';
  String _specialRequests = '';
  String _paymentMethod = 'Credit/Debit Card';

  // Availability
  Data? _availabilityData;
  List<DateTime> _availableDates = [];
  List<String> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAvailability();
    });
  }

  Future<void> _fetchAvailability() async {
    setState(() => _isLoadingAvailability = true);
    final providerId = widget.service?['providerId'] ??
        widget.service?['provider']?['_id'] ??
        widget.service?['provider']?['id'];
    debugPrint('📅 BookingScreen: Fetching availability for: $providerId');

    if (providerId != null) {
      final controller = context.read<CalenderAvailibilityController>();
      final model = await controller.getAvailabilitySettings(
          providerId: providerId.toString());
      if (mounted && model?.data != null) {
        setState(() {
          _availabilityData = model!.data;
          _buildAvailableDates();
        });
      }
    } else {
      // No provider id — generate default 14 days
      _buildAvailableDates();
    }
    if (mounted) setState(() => _isLoadingAvailability = false);
  }

  void _buildAvailableDates() {
    final List<DateTime> dates = [];
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = DateTime(now.year, now.month, now.day + i);
      if (_isDayWorking(date)) dates.add(date);
      if (dates.length >= 14) break;
    }
    setState(() => _availableDates = dates);
  }

  bool _isDayWorking(DateTime date) {
    if (_availabilityData == null) return true;

    if (_availabilityData!.customDates != null) {
      for (var cd in _availabilityData!.customDates!) {
        if (cd.date != null) {
          final exDate = DateTime.tryParse(cd.date!);
          if (exDate != null &&
              exDate.year == date.year &&
              exDate.month == date.month &&
              exDate.day == date.day) {
            return cd.type == 'available';
          }
        }
      }
    }

    Monday? daySchedule;
    switch (date.weekday) {
      case DateTime.monday:
        daySchedule = _availabilityData!.defaultSchedule?.monday;
        break;
      case DateTime.tuesday:
        daySchedule = _availabilityData!.defaultSchedule?.tuesday;
        break;
      case DateTime.wednesday:
        daySchedule = _availabilityData!.defaultSchedule?.wednesday;
        break;
      case DateTime.thursday:
        daySchedule = _availabilityData!.defaultSchedule?.thursday;
        break;
      case DateTime.friday:
        daySchedule = _availabilityData!.defaultSchedule?.friday;
        break;
      case DateTime.saturday:
        daySchedule = _availabilityData!.defaultSchedule?.saturday;
        break;
      case DateTime.sunday:
        daySchedule = _availabilityData!.defaultSchedule?.sunday;
        break;
    }
    return daySchedule?.isActive ?? true;
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDateTime = date;
      _selectedTime = '';
    });
    _buildTimeSlotsForDate(date);
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
          SizedBox(height: 10.h),
          Divider(color: Colors.grey.withOpacity(0.1)),
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
          _isLoadingAvailability
              ? const Center(child: CircularProgressIndicator(color: Colors.black))
              : _buildDateGrid(),
          SizedBox(height: 30.h),
          // Only show time slots when a date has been selected
          if (_selectedDateTime != null) ...[
            Text('Time Slot',
                style: TextStyle(
                    fontSize: 14.sp.clamp(14, 16),
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 15.h),
            _buildTimeSlotGrid(),
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
          _isLoadingAvailability
              ? const Center(child: CircularProgressIndicator(color: Colors.black))
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
          _isLoadingAvailability
              ? const Center(child: CircularProgressIndicator(color: Colors.black))
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
          Text('Location Details',
              style: TextStyle(
                  fontSize: 16.sp.clamp(16, 18),
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text('Where should the session take place?',
              style: TextStyle(
                  fontSize: 13.sp.clamp(13, 14), color: Colors.grey)),
          SizedBox(height: 25.h),
          _buildInputLabel('Location Address'),
          _buildTextField(
            hint: 'Enter location address',
            icon: Icons.location_on_outlined,
            onChanged: (val) => _location = val,
          ),
          SizedBox(height: 25.h),
          _buildInputLabel('Special Requests (Optional)'),
          _buildTextField(
            hint: 'Any specific requirements or notes for the photographer',
            maxLines: 5,
            onChanged: (val) => _specialRequests = val,
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
                _buildReviewItem('Provider',
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

  Widget _buildStep4() {
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
                _buildPriceRow('Package Total', '€400'),
                _buildPriceRow('Service Fee (3%)', '€12'),
                const Divider(),
                _buildPriceRow('Total', '€412', isBold: true),
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

  Widget _buildBottomButton() {
    return GestureDetector(
      onTap: () {
        if (_pageIndex < 6) {
          int nextPageIndex = _pageIndex + 1;
          if (_pageIndex < 3) nextPageIndex = 3;
          _pageController.animateToPage(
            nextPageIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
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
          child: Text(
            'Continue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp.clamp(16, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
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
      Function(String)? onChanged}) {
    return TextField(
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

  Widget _buildReviewItem(String label, String value) {
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
                  fontWeight: FontWeight.w600)),
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
