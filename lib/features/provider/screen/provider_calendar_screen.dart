import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:intl/intl.dart';

class ProviderCalendarScreen extends StatefulWidget {
  const ProviderCalendarScreen({super.key});

  @override
  State<ProviderCalendarScreen> createState() => _ProviderCalendarScreenState();
}

class _ProviderCalendarScreenState extends State<ProviderCalendarScreen> {
  int _selectedViewIndex = 1; // 0: Week, 1: Month, 2: Year
  DateTime _currentDate = DateTime.now();
  DateTime? _selectedDate;

  // Automation Settings State
  String _selectedPricingModel = 'By Hour';
  final TextEditingController _defaultRateController = TextEditingController(text: '100');
  final TextEditingController _weekendRateController = TextEditingController(text: '120');
  List<String> _blockedDays = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = _currentDate;
  }

  @override
  void dispose() {
    _defaultRateController.dispose();
    _weekendRateController.dispose();
    super.dispose();
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
            icon: Icon(Icons.settings_outlined, color: Colors.black, size: 24.sp),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10.h),
          // View Toggle
          _buildViewToggle(),
          SizedBox(height: 20.h),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildSelectedView(),
            ),
          ),
        ],
      ),
      floatingActionButton: null,
    );
  }

  Widget _buildViewToggle() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
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
        // Month Selector
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
        // Day Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
              .map((day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: AppTypography.bodySmall,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
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
        _buildScheduleItem(
          title: 'Wedding Photography',
          client: 'Jennifer Smith',
          time: '10:00 AM',
          location: 'Central Park, NYC',
          cost: '€1200',
          status: 'confirmed',
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    // Adjusted weekday: (firstDayOfMonth.weekday - 1) makes Mon=0, Sun=6
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
        
        // Mocked indicators for demonstration
        bool hasBlocked = dayNum == 21;
        bool hasPending = dayNum == 22;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = DateTime(_currentDate.year, _currentDate.month, dayNum);
            });
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
                    color: isSelected ? Colors.black : Colors.black87,
                  ),
                ),
                if (hasBlocked || hasPending)
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    width: 4.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      color: hasBlocked ? Colors.green : Colors.orange,
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
                  style: TextStyle(fontSize: AppTypography.bodyLarge, fontWeight: FontWeight.bold),
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
              Text(client, style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey)),
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
                    Text(time, style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey)),
                    SizedBox(width: 15.w),
                    Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                cost,
                style: TextStyle(fontSize: AppTypography.bodyLarge, fontWeight: FontWeight.bold),
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
        // Automation Settings Card
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Automation Settings',
                      style: TextStyle(fontSize: AppTypography.h2, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.close, size: 18.sp, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              Text('Block Days', style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.grey[700])),
              SizedBox(height: 8.h),
              _buildBlockDaysDropdown(),
              SizedBox(height: 15.h),
              Text('Pricing Model', style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.grey[700])),
              SizedBox(height: 10.h),
              Row(
                children: [
                  _buildPricingOption('By Hour'),
                  SizedBox(width: 10.w),
                  _buildPricingOption('By Day'),
                  SizedBox(width: 10.w),
                  _buildPricingOption('By Service'),
                ],
              ),
              SizedBox(height: 15.h),
              Text('Default Rate (\$/hour)', style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.grey[700])),
              SizedBox(height: 8.h),
              _buildEditableRateField(_defaultRateController),
              SizedBox(height: 15.h),
              Text('Weekend Rate (\$/hour)', style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.grey[700])),
              SizedBox(height: 8.h),
              _buildEditableRateField(_weekendRateController),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved successfully!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text('Save Settings', style: TextStyle(color: Colors.white, fontSize: AppTypography.bodyLarge)),
              ),
            ],
          ),
        ),
        SizedBox(height: 30.h),
        // Day Labels for Week View
        Row(
           mainAxisAlignment: MainAxisAlignment.spaceAround,
           children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
               .map((day) => Expanded(
                     child: Text(
                       day,
                       textAlign: TextAlign.center,
                       style: TextStyle(
                         fontSize: 12.sp,
                         color: Colors.grey[400],
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                   ))
               .toList(),
         ),
         SizedBox(height: 10.h),
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceAround,
           children: List.generate(7, (index) => _buildWeekDayItem(index + 1)),
         ),
         SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildBlockDaysDropdown() {
    final allDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            _blockedDays.isEmpty ? 'Select days to block' : _blockedDays.join(', '),
            style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          items: allDays.map((day) {
            return DropdownMenuItem<String>(
              value: day,
              child: StatefulBuilder(
                builder: (context, setSubState) {
                  bool isChecked = _blockedDays.contains(day);
                  return CheckboxListTile(
                    title: Text(day, style: TextStyle(fontSize: AppTypography.bodyLarge)),
                    value: isChecked,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _blockedDays.add(day);
                        } else {
                          _blockedDays.remove(day);
                        }
                      });
                      setSubState(() {});
                    },
                    controlAffinity: ListTileControlAffinity.trailing,
                  );
                },
              ),
            );
          }).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget _buildPricingOption(String label) {
    bool isSelected = _selectedPricingModel == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPricingModel = label),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTypography.bodySmall,
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableRateField(TextEditingController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        style: TextStyle(fontSize: AppTypography.bodyLarge, color: Colors.black),
      ),
    );
  }

  Widget _buildWeekDayItem(int dayOffset) {
    // Basic week view logic
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFB),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Text(
              dayOffset.toString(),
              style: TextStyle(fontSize: AppTypography.h2, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5.h),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildYearView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year Selector
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
        // Month Grid
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
                  _selectedViewIndex = 1; // Switch to Month view
                });
              },
              child: Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[100]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      monthName,
                      style: TextStyle(fontSize: AppTypography.bodyLarge, fontWeight: FontWeight.w600),
                    ),
                    if (index == 11) ...[ // Mock example for December
                      SizedBox(height: 5.h),
                      Text(
                        '2 bookings',
                        style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey[400]),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  void _showSetAvailabilityDialog(BuildContext context, {required DateTime date}) {
    final TextEditingController rateController = TextEditingController(text: _defaultRateController.text);
    bool isUnavailable = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.r),
            ),
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Set Availability',
                      style: TextStyle(fontSize: AppTypography.h1, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, size: 24.sp, color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text('Date', style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.grey[700])),
                SizedBox(height: 8.h),
                _buildDropdown(DateFormat('EEE MMM dd yyyy').format(date)),
                SizedBox(height: 15.h),
                Text('Hourly Rate (\$/)', style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.grey[700])),
                SizedBox(height: 8.h),
                _buildEditableRateField(rateController),
                SizedBox(height: 15.h),
                Text('Available Hours', style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.grey[700])),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('From', style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey)),
                        SizedBox(height: 4.h),
                        _buildTextField('09:00 AM'),
                      ],
                    )),
                    SizedBox(width: 15.w),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('To', style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey)),
                        SizedBox(height: 4.h),
                        _buildTextField('05:00 PM'),
                      ],
                    )),
                  ],
                ),
                SizedBox(height: 15.h),
                GestureDetector(
                  onTap: () => setDialogState(() => isUnavailable = !isUnavailable),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mark as unavailable', style: TextStyle(fontSize: AppTypography.bodyLarge, fontWeight: FontWeight.w500)),
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isUnavailable ? Colors.black : Colors.grey[400]!),
                        ),
                        child: Center(
                          child: isUnavailable ? Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                          ) : null,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(0, 50.h),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text('Cancel', style: TextStyle(color: Colors.black, fontSize: AppTypography.bodyLarge)),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Availability set for ${DateFormat('MMM dd').format(date)}')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(0, 50.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Text('Save', style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
          Icon(Icons.keyboard_arrow_down, size: 20.sp, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildTextField(String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(value, style: TextStyle(fontSize: 14.sp, color: Colors.black)),
    );
  }
}

