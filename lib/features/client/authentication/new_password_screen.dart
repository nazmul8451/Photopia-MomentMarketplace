import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/core/constants/app_sizes.dart';
import 'package:photopia/features/client/authentication/widgets/auth_widgets.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/reset_password_controller.dart';
import 'package:photopia/core/widgets/custom_snacbar.dart';

class NewPasswordScreen extends StatefulWidget {
  static const String name = '/new_password';
  final String email;
  final String token;

  const NewPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isNewPasswordValid = false;
  bool _isConfirmPasswordValid = false;

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
      _isConfirmPasswordValid =
          value.length >= 6 && value == _newPasswordController.text;
    });
  }

  Future<void> _submitNewPassword() async {
    if (_isNewPasswordValid && _isConfirmPasswordValid) {
      final resetPassController = context.read<ResetPasswordController>();
      final result = await resetPassController.resetPassword(
        widget.email,
        widget.token,
        _newPasswordController.text,
      );

      if (result && mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Password reset successfully! Please log in.',
          isError: false,
        );
        Navigator.pushNamedAndRemoveUntil(context, '/log_in', (route) => false);
      } else if (mounted) {
        CustomSnackBar.show(
          context: context,
          message:
              resetPassController.errorMessage ?? 'Failed to reset password',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                AuthTextField(
                  label: 'New Password',
                  controller: _newPasswordController,
                  hintText: '••••••••••',
                  isValid: _isNewPasswordValid,
                  onChanged: _validateNewPassword,
                  isPassword: true,
                ),

                SizedBox(height: AppSizes.spacingMedium),

                // Confirm Password Field
                AuthTextField(
                  label: 'Confirmed Password',
                  controller: _confirmPasswordController,
                  hintText: '••••••••••',
                  isValid: _isConfirmPasswordValid,
                  onChanged: _validateConfirmPassword,
                  isPassword: true,
                ),

                SizedBox(height: 32.h.clamp(32, 40)),

                // Submit Button
                Consumer<ResetPasswordController>(
                  builder: (context, controller, child) {
                    return AuthButton(
                      text: 'Submit',
                      onTap: _submitNewPassword,
                      isEnabled:
                          (_isNewPasswordValid && _isConfirmPasswordValid),
                      isLoading: controller.inProgress,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
