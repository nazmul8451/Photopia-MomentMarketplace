import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';

/// Reusable custom text field for authentication screens
class AuthTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool isValid;
  final Function(String) onChanged;
  final bool isPassword;
  final TextInputType keyboardType;
  final bool showValidationIcon;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.isValid,
    required this.onChanged,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.showValidationIcon = true,
  });

  @override
  Widget build(BuildContext context) {
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
              suffixIcon: showValidationIcon && controller.text.isNotEmpty
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
}

/// Reusable primary button for authentication screens
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isEnabled;

  const AuthButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: double.infinity,
        height: 50.h.clamp(50, 56),
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFF1A1A1A) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isEnabled ? Colors.white : Colors.grey.shade500,
            fontSize: AppTypography.bodyLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Reusable social login/signup button
class SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
