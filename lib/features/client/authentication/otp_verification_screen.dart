import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/features/client/authentication/widgets/auth_widgets.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/verify_otp_controller.dart';

class OtpVerificationScreen extends StatefulWidget {
  static const String name = '/otp_verification';
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool _isOtpComplete() {
    return _otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  Future<void> _submitOtp() async {
    if (_isOtpComplete()) {
      String otp = _otpControllers.map((c) => c.text).join();
      final verifyOtpController = Provider.of<VerifyOtpController>(
        context,
        listen: false,
      );

      final result = await verifyOtpController.verifyOtp(widget.email, otp);

      if (result) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification successful! Please log in.'),
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/log_in',
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                verifyOtpController.errorMessage ?? 'Verification failed',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h.clamp(16, 20)),

              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back,
                  size: 24.sp.clamp(24, 28),
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 32.h.clamp(32, 40)),

              // Title
              Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 24.sp.clamp(24, 28),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 12.h.clamp(12, 16)),

              // Subtitle
              Text(
                'Code Submit',
                style: TextStyle(
                  fontSize: 18.sp.clamp(18, 20),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 8.h.clamp(8, 12)),

              Text(
                'Enter the 6-Digit code sent to you at\n${widget.email}',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 32.h.clamp(32, 40)),

              // OTP Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _buildOtpBox(index)),
              ),

              SizedBox(height: 32.h.clamp(32, 40)),

              // Submit Button
              Consumer<VerifyOtpController>(
                builder: (context, controller, child) {
                  return AuthButton(
                    text: 'Submit',
                    isLoading: controller.inProgress,
                    onTap: _submitOtp,
                    isEnabled: _isOtpComplete() && !controller.inProgress,
                  );
                },
              ),

              SizedBox(height: 16.h.clamp(16, 20)),

              // Resend Link
              Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Implement resend OTP logic
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Didn't receive code?  ",
                      style: TextStyle(
                        fontSize: AppTypography.bodyMedium,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(
                          text: 'Resend Again',
                          style: TextStyle(
                            fontSize: AppTypography.bodyMedium,
                            color: const Color(0xFF2196F3),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 45.w.clamp(40, 60),
      height: 55.h.clamp(45, 65),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _otpControllers[index].text.isNotEmpty
              ? const Color(0xFF1A1A1A)
              : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24.sp.clamp(24, 28),
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
