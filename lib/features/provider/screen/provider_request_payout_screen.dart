import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/core/constants/app_sizes.dart';
import 'package:photopia/controller/provider/wallet_controller.dart';
import 'package:photopia/core/widgets/custom_snacbar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProviderRequestPayoutScreen extends StatefulWidget {
  const ProviderRequestPayoutScreen({super.key});

  @override
  State<ProviderRequestPayoutScreen> createState() => _ProviderRequestPayoutScreenState();
}

class _ProviderRequestPayoutScreenState extends State<ProviderRequestPayoutScreen> with WidgetsBindingObserver {
  late TextEditingController _amountController;
  String _selectedMethod = 'Withdraw Balance';
  String? _selectedPercentage = 'All';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '0.00');
    // Add observer to detect when app returns to foreground
    WidgetsBinding.instance.addObserver(this);
    // Fetch wallet data if not already loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletController>().getMyWallet();
      context.read<WalletController>().getStripeStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _amountController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh status when user returns from browser
      debugPrint("🔄 App resumed. Refreshing Stripe status...");
      context.read<WalletController>().getStripeStatus();
    }
  }

  void _updateAmount(String percentage, double currentBalance) {
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
    
    final newAmount = currentBalance * factor;
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
      body: Consumer<WalletController>(
        builder: (context, walletController, child) {
          final double balance = (walletController.walletData?.balance ?? 0).toDouble();
          
          // Fallback to update controller text only if it was 0 and we have balance now
          if (_amountController.text == '0.00' && balance > 0 && _selectedPercentage == 'All') {
            _amountController.text = balance.toStringAsFixed(2);
          } else if (_amountController.text == '0.00' && balance > 0 && _selectedPercentage == null) {
             // Optional: preset but usually let user type
          }

          if (walletController.isLoading && walletController.walletData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
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
                        '€${balance.toStringAsFixed(2)}',
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
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  ),
                ),
                SizedBox(height: 12.h),

                // Percentage Buttons
                Row(
                  children: [
                    _buildPercentButton('25%', balance),
                    SizedBox(width: 8.w),
                    _buildPercentButton('50%', balance),
                    SizedBox(width: 8.w),
                    _buildPercentButton('75%', balance),
                    SizedBox(width: 8.w),
                    _buildPercentButton('All', balance),
                  ],
                ),
                SizedBox(height: 24.h),

                // Payment Method
                Text('Payment Method', style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.grey)),
                SizedBox(height: 12.h),
                _buildPaymentMethodItem(
                  icon: Icons.account_balance, 
                  title: 'Withdraw Balance', 
                  subtitle: 'Bank Transfer\n2-3 business days', 
                  isSelected: _selectedMethod == 'Withdraw Balance',
                  onTap: () => setState(() => _selectedMethod = 'Withdraw Balance'),
                ),

                SizedBox(height: 32.h),

                // Summary
                Text('Payout Summary', style: TextStyle(fontSize: AppTypography.bodyMedium, color: Colors.grey)),
                SizedBox(height: 12.h),
                _buildSummaryRow('Payout Amount', '€${_amountController.text}'),
                SizedBox(height: 8.h),
                _buildSummaryRow('You\'ll Receive', '€${_amountController.text}', isTotal: true),

                SizedBox(height: 32.h),

                // Request/Connect Button
                SizedBox(
                   width: double.infinity,
                   height: AppSizes.fieldHeight,
                   child: ElevatedButton(
                     onPressed: walletController.isLoading 
                       ? null 
                       : () async {
                         if (walletController.isStripeReady) {
                           // 1. Get and validate amount
                           final amountStr = _amountController.text;
                           final amount = double.tryParse(amountStr) ?? 0.0;
                           
                           if (amount <= 0) {
                             CustomSnackBar.show(
                               context: context,
                               message: 'Please enter a valid payout amount',
                               isError: true,
                             );
                             return;
                           }

                           // 2. Call API
                           final success = await walletController.createWithdrawal(amount);

                           if (success && context.mounted) {
                             // Show success dialog (Existing payout request logic)
                             _showSuccessDialog(context);
                           } else if (context.mounted) {
                             CustomSnackBar.show(
                               context: context,
                               message: 'Withdrawal failed. Please check your balance.',
                               isError: true,
                             );
                           }
                         } else {
                           // Handle Stripe Onboarding
                           final url = await walletController.getStripeOnboardingUrl();
                           if (url != null && context.mounted) {
                             final uri = Uri.parse(url);
                             if (await canLaunchUrl(uri)) {
                               await launchUrl(uri, mode: LaunchMode.externalApplication);
                             } else {
                               CustomSnackBar.show(
                                 context: context,
                                 message: 'Could not launch onboarding URL',
                                 isError: true,
                               );
                             }
                           }
                         }
                     },
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.black,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.borderRadius)),
                     ),
                     child: walletController.isLoading 
                       ? SizedBox(
                           height: 20.sp, 
                           width: 20.sp, 
                           child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                         )
                       : Text(
                           walletController.isStripeReady ? 'Request Payout' : 'Connect Stripe Account', 
                           style: TextStyle(
                             fontSize: AppTypography.bodyLarge,
                             color: Colors.white,
                             fontWeight: FontWeight.w600,
                           ),
                         ),
                   ),
                 ),
                 SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPercentButton(String label, double currentBalance) {
    final isSelected = _selectedPercentage == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => _updateAmount(label, currentBalance),
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
