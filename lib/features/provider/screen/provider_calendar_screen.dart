import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/provider/screen/provider_availability_settings_screen.dart';
import 'package:photopia/controller/provider/calender_availibility_controller.dart';
import 'package:photopia/controller/client/user_profile_controller.dart';
import 'package:photopia/data/models/calender_availibility_model.dart';
import 'package:provider/provider.dart';

class ProviderCalendarScreen extends StatefulWidget {
  const ProviderCalendarScreen({super.key});

  @override
  State<ProviderCalendarScreen> createState() => _ProviderCalendarScreenState();
}

class _ProviderCalendarScreenState extends State<ProviderCalendarScreen> {
  int _selectedViewIndex = 1; // 0: Week, 1: Month, 2: Year
  DateTime _currentDate = DateTime.now();
  DateTime? _selectedDate;
  bool _isLoading = false;
  Data? _availabilityData;

  @override
  void initState() {
    super.initState();
    _selectedDate = _currentDate;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAvailabilityData();
      _fetchBookingsForDate(_selectedDate ?? _currentDate);
    });
  }

  Future<void> _fetchBookingsForDate(DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final controller = context.read<CalenderAvailibilityController>();
    await controller.getBookingsByDate(date: formattedDate);
  }

  Future<void> _fetchAvailabilityData() async {
    setState(() => _isLoading = true);
    final availabilityController = context.read<CalenderAvailibilityController>();
    final profileController = context.read<UserProfileController>();
    
    if (profileController.userProfile == null) {
      await profileController.getUserProfile();
    }

    final String? providerId = profileController.userProfile?.id;
    debugPrint('🔍 Fetching availability for ProviderID: $providerId');
    
    if (providerId != null) {
      final settingsModel = await availabilityController.getAvailabilitySettings(providerId: providerId);
      if (mounted && settingsModel != null) {
        debugPrint('✅ Availability Data Received: ${settingsModel.data?.defaultSchedule?.monday?.isActive}');
        setState(() {
          _availabilityData = settingsModel.data;
        });
      }
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  // Helper to check if a specific date is "Working"
  bool _isDayWorking(DateTime date) {
    if (_availabilityData == null) return true;

    // 1. Check Custom Dates (Exceptions) first
    
    if (_availabilityData!.customDates != null) {
      for (var cd in _availabilityData!.customDates!) {
        if (cd.date != null) {
          DateTime? exceptionDate = DateTime.tryParse(cd.date!);
          if (exceptionDate != null && 
              exceptionDate.year == date.year && 
              exceptionDate.month == date.month && 
              exceptionDate.day == date.day) {
            return cd.type == 'available';
          }
        }
      }
    }

    // 2. Check Default Schedule using weekday integer (1=Mon, 7=Sun)
    Monday? daySchedule;
    switch (date.weekday) {
      case DateTime.monday: daySchedule = _availabilityData!.defaultSchedule?.monday; break;
      case DateTime.tuesday: daySchedule = _availabilityData!.defaultSchedule?.tuesday; break;
      case DateTime.wednesday: daySchedule = _availabilityData!.defaultSchedule?.wednesday; break;
      case DateTime.thursday: daySchedule = _availabilityData!.defaultSchedule?.thursday; break;
      case DateTime.friday: daySchedule = _availabilityData!.defaultSchedule?.friday; break;
      case DateTime.saturday: daySchedule = _availabilityData!.defaultSchedule?.saturday; break;
      case DateTime.sunday: daySchedule = _availabilityData!.defaultSchedule?.sunday; break;
    }

    return daySchedule?.isActive ?? true;
  }

  void _nextMonth() {
    setState(() {
      if (_selectedViewIndex == 2) {
        _currentDate = DateTime(_currentDate.year + 1, _currentDate.month);
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      }
    });
  }

  void _previousMonth() {
    setState(() {
      if (_selectedViewIndex == 2) {
        _currentDate = DateTime(_currentDate.year - 1, _currentDate.month);
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Calendar & Availability',
          style: TextStyle(
            color: Colors.black,
            fontSize: AppTypography.h1,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.black,
              size: 24.sp,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProviderAvailabilitySettingsScreen(),
                ),
              );
              // Re-fetch data on return
              _fetchAvailabilityData();
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _buildCalendarView(),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        SizedBox(height: 10.h),
        _buildViewToggle(),
        SizedBox(height: 20.h),
        _buildSelectedView(),
      ],
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          _buildToggleItem('Week', 0),
          _buildToggleItem('Month', 1),
          _buildToggleItem('Year', 2),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, int index) {
    bool isSelected = _selectedViewIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedViewIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTypography.bodyLarge,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedView() {
    switch (_selectedViewIndex) {
      case 0:
        return _buildWeekView();
      case 1:
        return _buildMonthView();
      case 2:
        return _buildYearView();
      default:
        return const SizedBox();
    }
  }

  Widget _buildMonthView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _previousMonth,
              icon: Icon(Icons.chevron_left, size: 24.sp),
            ),
            Text(
              DateFormat('MMMM yyyy').format(_currentDate),
              style: TextStyle(
                fontSize: AppTypography.h2,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: _nextMonth,
              icon: Icon(Icons.chevron_right, size: 24.sp),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map(
                (day) => Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 10.h),
        _buildCalendarGrid(),
        SizedBox(height: 30.h),
        Text(
          'Monthly Schedule',
          style: TextStyle(
            fontSize: AppTypography.h1,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15.h),
        Consumer<CalenderAvailibilityController>(
          builder: (context, controller, child) {
            if (controller.inProgress && controller.bookingsForSelectedDate.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.bookingsForSelectedDate.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Text(
                    'No bookings for this date',
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  ),
                ),
              );
            }

            return Column(
              children: controller.bookingsForSelectedDate.map((booking) {
                final pricing = booking['pricingDetails'];
                final service = booking['serviceId'];
                
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildScheduleItem(
                    title: service?['title'] ?? booking['eventType'] ?? 'Booking',
                    client: booking['clientName'] ?? booking['clientId']?['name'] ?? 'Client',
                    time: booking['startTime'] ?? 'N/A',
                    location: booking['eventLocation']?['address'] ?? 'N/A',
                    cost: '€${pricing?['subtotal'] ?? '0'}',
                    status: booking['status'] ?? 'pending',
                  ),
                );
              }).toList(),
            );
          },
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday - 1;

    final totalItems = daysInMonth + firstWeekday;
    final rowCount = (totalItems / 7).ceil();
    final gridItems = rowCount * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemCount: gridItems,
      itemBuilder: (context, index) {
        int dayNum = index - firstWeekday + 1;
        if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox();

        bool isSelected = _selectedDate?.day == dayNum &&
            _selectedDate?.month == _currentDate.month &&
            _selectedDate?.year == _currentDate.year;

        DateTime date = DateTime(_currentDate.year, _currentDate.month, dayNum);
        bool isWorking = _isDayWorking(date);
        
        // Mock data for blocked/pending indicators for now
        bool hasBlocked = dayNum == 21; 
        bool hasPending = dayNum == 22;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
            _fetchBookingsForDate(date);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF3F3F3) : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: isSelected ? Border.all(color: Colors.black12) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayNum.toString(),
                  style: TextStyle(
                    fontSize: AppTypography.bodyLarge,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                    color: isWorking ? Colors.black : Colors.grey[300],
                  ),
                ),
                if (isWorking)
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    width: 4.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      color: hasBlocked ? Colors.red : (hasPending ? Colors.orange : Colors.green),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduleItem({
    required String title,
    required String client,
    required String time,
    required String location,
    required String cost,
    required String status,
  }) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey[100]!),
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
                  title,
                  style: TextStyle(
                    fontSize: AppTypography.bodyLarge,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: AppTypography.bodySmall,
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14.sp, color: Colors.grey),
              SizedBox(width: 5.w),
              Text(
                client,
                style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 5.w),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: AppTypography.bodySmall,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: AppTypography.bodySmall,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                cost,
                style: TextStyle(
                  fontSize: AppTypography.bodyLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Overview',
          style: TextStyle(
            fontSize: AppTypography.h1,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map(
                (day) => Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) => _buildWeekDayItem(index + 1)),
        ),
        SizedBox(height: 30.h),
        Text(
          'Upcoming this week',
          style: TextStyle(
            fontSize: AppTypography.h2,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 15.h),
        _buildScheduleItem(
          title: 'Fashion Shoot',
          client: 'Marc Jacobs',
          time: '2:00 PM',
          location: 'SoHo Studio',
          cost: '€450',
          status: 'pending',
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildWeekDayItem(int dayOffset) {
    // Calculate the date for this day of the week
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final date = firstDayOfWeek.add(Duration(days: dayOffset - 1));
    bool isWorking = _isDayWorking(date);

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: isWorking ? const Color(0xFFFBFBFB) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: isWorking ? Colors.grey[200]! : Colors.grey[100]!),
        ),
        child: Column(
          children: [
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: AppTypography.h2,
                fontWeight: FontWeight.bold,
                color: isWorking ? Colors.black : Colors.grey[400],
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              isWorking ? 'ON' : 'OFF',
              style: TextStyle(
                fontSize: 8.sp,
                fontWeight: FontWeight.w600,
                color: isWorking ? Colors.green : Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _previousMonth,
              icon: Icon(Icons.chevron_left, size: 24.sp),
            ),
            Text(
              _currentDate.year.toString(),
              style: TextStyle(
                fontSize: AppTypography.h1,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _nextMonth,
              icon: Icon(Icons.chevron_right, size: 24.sp),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 100.h,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            String monthName = DateFormat('MMMM').format(DateTime(_currentDate.year, index + 1));
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentDate = DateTime(_currentDate.year, index + 1);
                  _selectedViewIndex = 1;
                });
              },
              child: Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Center(
                  child: Text(
                    monthName,
                    style: TextStyle(
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
