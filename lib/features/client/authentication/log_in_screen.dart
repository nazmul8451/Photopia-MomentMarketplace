import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';

class LogInScreen extends StatefulWidget {
  static const String name = '/log_in';
  
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                  'Log in to continue',
                  style: TextStyle(
                    fontSize: 24.sp.clamp(24, 28),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                
                SizedBox(height: 32.h.clamp(32, 40)),
                
                // Email Field
                _buildInputField(
                  label: 'Email',
                  controller: _emailController,
                  hintText: 'your@email.com',
                  isValid: _isEmailValid,
                  onChanged: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                
                SizedBox(height: 20.h.clamp(20, 24)),
                
                // Password Field
                _buildInputField(
                  label: 'Password',
                  controller: _passwordController,
                  hintText: '••••••••••',
                  isValid: _isPasswordValid,
                  onChanged: _validatePassword,
                  isPassword: true,
                ),
                
                SizedBox(height: 12.h.clamp(12, 16)),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/forgot_password');
                    },
                    child: Text(
                      'Forget Password?',
                      style: TextStyle(
                        fontSize: AppTypography.bodyMedium,
                        color: const Color(0xFF2196F3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 32.h.clamp(32, 40)),
                
                // Login Button
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/bottom-navigation',
                      (route) => false,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50.h.clamp(50, 56),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTypography.bodyLarge,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
                
                // Social Login Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildSocialButton(
                        icon: Icons.g_mobiledata,
                        label: 'Google',
                        onTap: () {
                          // TODO: Implement Google login
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildSocialButton(
                        icon: Icons.facebook,
                        label: 'Facebook',
                        onTap: () {
                          // TODO: Implement Facebook login
                        },
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 32.h.clamp(32, 40)),
                
                // Sign Up Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/sign_up');
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          fontSize: AppTypography.bodyMedium,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign up',
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool isValid,
    required Function(String) onChanged,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: AppTypography.bodyMedium,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: AppTypography.bodyMedium,
                color: Colors.grey.shade400,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? Icon(
                      isValid ? Icons.check : null,
                      color: Colors.grey.shade400,
                      size: 20.sp.clamp(20, 24),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h.clamp(50, 56),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24.sp.clamp(24, 28),
              color: icon == Icons.g_mobiledata 
                  ? const Color(0xFFDB4437) 
                  : const Color(0xFF1877F2),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: AppTypography.bodyMedium,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
