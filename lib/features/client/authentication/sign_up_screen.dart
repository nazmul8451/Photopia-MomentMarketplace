import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/core/constants/app_sizes.dart';
import 'package:photopia/features/client/authentication/widgets/auth_widgets.dart';

class SignUpScreen extends StatefulWidget {
  static const String name = '/sign_up';
  
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isNameValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateName(String value) {
    setState(() {
      _isNameValid = value.length >= 2;
    });
  }

  void _validateEmail(String value) {
    setState(() {
      _isEmailValid = value.contains('@') && value.length > 3;
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _isPasswordValid = value.length >= 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                  'Create Account',
                  style: TextStyle(
                    fontSize: 24.sp.clamp(24, 28),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                
                SizedBox(height: 32.h.clamp(32, 40)),
                
                // Name Field
                AuthTextField(
                  label: 'Name',
                  controller: _nameController,
                  hintText: 'Photopia',
                  isValid: _isNameValid,
                  onChanged: _validateName,
                ),
                
                SizedBox(height: AppSizes.spacingMedium),
                
                // Email Field
                AuthTextField(
                  label: 'Email',
                  controller: _emailController,
                  hintText: 'your@email.com',
                  isValid: _isEmailValid,
                  onChanged: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                
                SizedBox(height: AppSizes.spacingMedium),
                
                // Password Field
                AuthTextField(
                  label: 'Password',
                  controller: _passwordController,
                  hintText: '••••••••••',
                  isValid: _isPasswordValid,
                  onChanged: _validatePassword,
                  isPassword: true,
                ),
                
                SizedBox(height: AppSizes.spacingLarge),
                
                // Sign Up Button
                AuthButton(
                  text: 'Sign Up',
                  onTap: () {
                    // TODO: Implement sign up logic
                  },
                ),
                
                SizedBox(height: 24.h.clamp(24, 28)),
                
                // OR CONTINUE WITH
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: TextStyle(
                          fontSize: AppTypography.bodySmall,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                
                SizedBox(height: 24.h.clamp(24, 28)),
                
                // Social Sign Up Buttons
                Row(
                  children: [
                    Expanded(
                      child: SocialButton(
                        icon: Icons.g_mobiledata,
                        label: 'Google',
                        onTap: () {
                          // TODO: Implement Google sign up
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: SocialButton(
                        icon: Icons.facebook,
                        label: 'Facebook',
                        onTap: () {
                          // TODO: Implement Facebook sign up
                        },
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 32.h.clamp(32, 40)),
                
                // Log In Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                          fontSize: AppTypography.bodyMedium,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: 'Log in',
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
                
                SizedBox(height: 24.h.clamp(24, 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
