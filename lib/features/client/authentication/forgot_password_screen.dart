import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String name = '/forgot_password';
  
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isEmailValid = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() {
      _isEmailValid = value.contains('@') && value.length > 3;
    });
  }

  void _sendResetLink() {
    if (_isEmailValid) {
      // TODO: Implement send reset link logic
      Navigator.pushNamed(
        context,
        '/otp_verification',
        arguments: _emailController.text,
      );
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
                'Enter your email address and we will send\nyou a reset instructions.',
                style: TextStyle(
                  fontSize: AppTypography.bodyMedium,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 32.h.clamp(32, 40)),
              
              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: AppTypography.bodyMedium,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.h.clamp(8, 12)),
                  Container(
                    height: 50.h.clamp(50, 56),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: _validateEmail,
                      style: TextStyle(
                        fontSize: AppTypography.bodyMedium,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'your@email.com',
                        hintStyle: TextStyle(
                          fontSize: AppTypography.bodyMedium,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 32.h.clamp(32, 40)),
              
              // Send Button
              GestureDetector(
                onTap: _sendResetLink,
                child: Container(
                  width: double.infinity,
                  height: 50.h.clamp(50, 56),
                  decoration: BoxDecoration(
                    color: _isEmailValid ? const Color(0xFF1A1A1A) : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Send',
                    style: TextStyle(
                      color: _isEmailValid ? Colors.white : Colors.grey.shade500,
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
                    // TODO: Implement resend logic
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
}
