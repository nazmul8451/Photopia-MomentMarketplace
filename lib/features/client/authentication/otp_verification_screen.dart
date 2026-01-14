import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';

class OtpVerificationScreen extends StatefulWidget {
  static const String name = '/otp_verification';
  final String email;
  
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

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

  void _submitOtp() {
    if (_isOtpComplete()) {
      String otp = _otpControllers.map((c) => c.text).join();
      // TODO: Implement OTP verification logic
      Navigator.pushNamed(context, '/new_password');
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
                'Forget Password',
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
                'Enter the 4-Digit code sent to you at\n${widget.email}',
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
                children: List.generate(4, (index) => _buildOtpBox(index)),
              ),
              
              SizedBox(height: 32.h.clamp(32, 40)),
              
              // Submit Button
              GestureDetector(
                onTap: _submitOtp,
                child: Container(
                  width: double.infinity,
                  height: 50.h.clamp(50, 56),
                  decoration: BoxDecoration(
                    color: _isOtpComplete() ? const Color(0xFF1A1A1A) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: _isOtpComplete() ? Colors.white : Colors.grey.shade500,
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
      width: 60.w.clamp(50, 70),
      height: 60.h.clamp(50, 70),
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
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
