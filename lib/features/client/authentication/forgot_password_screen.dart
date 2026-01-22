import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/core/constants/app_sizes.dart';
import 'package:photopia/features/client/authentication/widgets/auth_widgets.dart';

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
              AuthTextField(
                label: 'Email',
                controller: _emailController,
                hintText: 'your@email.com',
                isValid: _isEmailValid,
                onChanged: _validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              
              SizedBox(height: 32.h.clamp(32, 40)),
              
              // Send Button
              AuthButton(
                text: 'Send',
                onTap: _sendResetLink,
                isEnabled: _isEmailValid,
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
