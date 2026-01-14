import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';

class NewPasswordScreen extends StatefulWidget {
  static const String name = '/new_password';
  
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isNewPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateNewPassword(String value) {
    setState(() {
      _isNewPasswordValid = value.length >= 6;
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      _isConfirmPasswordValid = value.length >= 6 && value == _newPasswordController.text;
    });
  }

  void _submitNewPassword() {
    if (_isNewPasswordValid && _isConfirmPasswordValid) {
      // TODO: Implement password reset logic
      // Show success message and navigate to login
      Navigator.popUntil(context, (route) => route.isFirst);
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
                'New password',
                style: TextStyle(
                  fontSize: 18.sp.clamp(18, 20),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              
              SizedBox(height: 32.h.clamp(32, 40)),
              
              // New Password Field
              _buildPasswordField(
                label: 'New Password',
                controller: _newPasswordController,
                hintText: '••••••••••',
                isValid: _isNewPasswordValid,
                onChanged: _validateNewPassword,
                obscureText: _obscureNewPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
              
              SizedBox(height: 20.h.clamp(20, 24)),
              
              // Confirm Password Field
              _buildPasswordField(
                label: 'Confirmed Password',
                controller: _confirmPasswordController,
                hintText: '••••••••••',
                isValid: _isConfirmPasswordValid,
                onChanged: _validateConfirmPassword,
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              
              SizedBox(height: 32.h.clamp(32, 40)),
              
              // Submit Button
              GestureDetector(
                onTap: _submitNewPassword,
                child: Container(
                  width: double.infinity,
                  height: 50.h.clamp(50, 56),
                  decoration: BoxDecoration(
                    color: (_isNewPasswordValid && _isConfirmPasswordValid) 
                        ? const Color(0xFF1A1A1A) 
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: (_isNewPasswordValid && _isConfirmPasswordValid) 
                          ? Colors.white 
                          : Colors.grey.shade500,
                      fontSize: AppTypography.bodyLarge,
                      fontWeight: FontWeight.w600,
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool isValid,
    required Function(String) onChanged,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
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
            obscureText: obscureText,
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
                  ? IconButton(
                      icon: Icon(
                        isValid ? Icons.check : null,
                        color: Colors.grey.shade400,
                        size: 20.sp.clamp(20, 24),
                      ),
                      onPressed: null,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
