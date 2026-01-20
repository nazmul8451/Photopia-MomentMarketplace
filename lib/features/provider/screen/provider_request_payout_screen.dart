import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';

class ProviderRequestPayoutScreen extends StatefulWidget {
  const ProviderRequestPayoutScreen({super.key});

  @override
  State<ProviderRequestPayoutScreen> createState() => _ProviderRequestPayoutScreenState();
}

class _ProviderRequestPayoutScreenState extends State<ProviderRequestPayoutScreen> {
  final double _availableBalance = 4250.00;
  late TextEditingController _amountController;
  String _selectedMethod = 'Bank Transfer';
  String? _selectedPercentage = 'All';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: _availableBalance.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateAmount(String percentage) {
    double factor = 0.0;
    switch (percentage) {
      case '25%':
        factor = 0.25;
        break;
      case '50%':
        factor = 0.50;
        break;
      case '75%':
        factor = 0.75;
        break;
      case 'All':
        factor = 1.0;
        break;
    }
    
    final newAmount = _availableBalance * factor;
    setState(() {
      _selectedPercentage = percentage;
      _amountController.text = newAmount.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Request Payout',
          style: TextStyle(
            fontSize: AppTypography.h1,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Balance Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.white, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Available Balance',
                        style: TextStyle(
                          fontSize: AppTypography.bodyMedium,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '€${_availableBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Minimum payout: €50.00',
                    style: TextStyle(
                      fontSize: AppTypography.bodySmall,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Payout Amount
            Text('Payout Amount', style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.grey)),
            SizedBox(height: 8.h),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                if (_selectedPercentage != null) {
                  setState(() {
                    _selectedPercentage = null;
                  });
                }
              },
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixText: '€ ',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              ),
            ),
            SizedBox(height: 12.h),

            // Percentage Buttons
            Row(
              children: [
                _buildPercentButton('25%'),
                SizedBox(width: 8.w),
                _buildPercentButton('50%'),
                SizedBox(width: 8.w),
                _buildPercentButton('75%'),
                SizedBox(width: 8.w),
                _buildPercentButton('All'),
              ],
            ),
            SizedBox(height: 24.h),

            // Payment Method
            Text('Payment Method', style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.grey)),
            SizedBox(height: 12.h),
            _buildPaymentMethodItem(
              icon: Icons.account_balance, 
              title: 'Bank Transfer', 
              subtitle: '****1234\n2-3 business days', 
              isSelected: _selectedMethod == 'Bank Transfer',
              onTap: () => setState(() => _selectedMethod = 'Bank Transfer'),
            ),
            SizedBox(height: 12.h),
             _buildPaymentMethodItem(
              icon: Icons.payments, 
              title: 'PayPal', 
              subtitle: 'sarah.m@email.com\n1 business day', 
              isSelected: _selectedMethod == 'PayPal',
              trailing: '2.9% fee',
              onTap: () => setState(() => _selectedMethod = 'PayPal'),
            ),

            SizedBox(height: 32.h),

            // Summary
            Text('Payout Summary', style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.grey)),
            SizedBox(height: 12.h),
            _buildSummaryRow('Payout Amount', '€${_amountController.text}'),
            SizedBox(height: 8.h),
            _buildSummaryRow('You\'ll Receive', '€${_amountController.text}', isTotal: true),

            SizedBox(height: 32.h),

            // Request Button
            SizedBox(
               width: double.infinity,
               height: 52.h,
               child: ElevatedButton(
                 onPressed: () {
                     // Show success dialog
                     _showSuccessDialog(context);
                 },
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.black,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                 ),
                 child: Text('Request Payout', style: TextStyle(
                   fontSize: AppTypography.bodyLarge,
                   color: Colors.white,
                   fontWeight: FontWeight.w600,
                 )),
               ),
             ),
             SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentButton(String label) {
    final isSelected = _selectedPercentage == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => _updateAmount(label),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 24.sp, color: Colors.black),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    fontSize: AppTypography.bodyMedium,
                    fontWeight: FontWeight.w600,
                  )),
                  SizedBox(height: 4.h),
                  Text(subtitle, style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey)),
                ],
              ),
            ),
            if (trailing != null)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Text(trailing, style: TextStyle(
                  fontSize: AppTypography.bodySmall,
                  color: Colors.grey,
                )),
              ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.black, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontSize: isTotal ? 14.sp : 13.sp,
          color: isTotal ? Colors.black : Colors.grey[700],
          fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
        )),
        Text(value, style: TextStyle(
          fontSize: isTotal ? 16.sp : 14.sp,
          color: isTotal ? Colors.green : Colors.black,
          fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
        )),
      ],
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.green, size: 32.sp),
              ),
              SizedBox(height: 16.h),
              Text('Payout Requested!', style: TextStyle(
                fontSize: AppTypography.h1,
                fontWeight: FontWeight.bold,
              )),
              SizedBox(height: 8.h),
              Text(
                'Your payout request of €${_amountController.text} has been submitted successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.grey),
              ),
              SizedBox(height: 8.h),
               Text(
                'Funds will arrive in 2-3 business days',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppTypography.bodySmall, color: Colors.grey),
              ),
              SizedBox(height: 24.h),
               SizedBox(
               width: double.infinity,
               height: 48.h,
               child: OutlinedButton(
                 onPressed: () => Navigator.pop(context),
                 style: OutlinedButton.styleFrom(
                   side: const BorderSide(color: Colors.transparent),
                 ),
                 child: Text('Close', style: TextStyle(
                   fontSize: AppTypography.bodyLarge,
                   color: Colors.grey[800],
                   fontWeight: FontWeight.w600,
                 )),
               ),
             ),
            ],
          ),
        ),
      ),
    );
  }
}
