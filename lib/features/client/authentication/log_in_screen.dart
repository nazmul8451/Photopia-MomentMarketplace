import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/constants/app_typography.dart';
import 'package:photopia/core/constants/app_sizes.dart';
import 'package:photopia/features/client/authentication/widgets/auth_widgets.dart';
import 'package:provider/provider.dart';
import 'package:photopia/controller/client/sign_in_controller.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/widgets/custom_snacbar.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/core/notification/notification_service.dart';

class LogInScreen extends StatefulWidget {
  static const String name = '/log_in';
  final String userRole; // 'client' or 'provider'

  const LogInScreen({super.key, this.userRole = 'client'});

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

  void _clearControllers() {
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _isEmailValid = false;
      _isPasswordValid = false;
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

                SizedBox(height: 12.h.clamp(12, 16)),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      debugPrint('➡️ Navigating to Forgot Password, clearing controllers');
                      _clearControllers();
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

                SizedBox(height: AppSizes.spacingLarge),

                // Login Button
                Consumer<SignInController>(
                  builder: (context, signInController, child) {
                    return AuthButton(
                      text: 'Login',
                      isLoading: signInController.inProgress,
                      onTap: () async {
                        debugPrint('🚀 Login button clicked');
                        if (!_isEmailValid || !_isPasswordValid) {
                          debugPrint('⚠️ Validation failed: Email=$_isEmailValid, Password=$_isPasswordValid');
                          CustomSnackBar.show(
                            context: context,
                            message: 'Please enter valid email and password',
                            isError: true,
                          );
                          return;
                        }

                        debugPrint('📡 Calling signIn with: ${_emailController.text.trim()}');
                        final result = await signInController.signIn(
                          _emailController.text.trim(),
                          _passwordController.text,
                        );

                        debugPrint('🏁 Login result: $result');
                        if (result) {
                          if (mounted) {
                            debugPrint('✅ Login successful, traversing to active role app...');
                            
                            // Fetch profile explicitly if AuthController.activeRole isn't fully reliable via login payload (or it's cached)
                            String? resolvedRole = AuthController.activeRole;
                            try {
                               final profileResp = await NetworkCaller.getRequest(url: Urls.userProfile);
                               if (profileResp.isSuccess && profileResp.body != null) {
                                  resolvedRole = profileResp.body!['data']?['activeRole']?.toString() 
                                              ?? profileResp.body!['data']?['role']?.toString() 
                                              ?? resolvedRole;
                                  if (resolvedRole != null) {
                                    await AuthController.saveUserRole(resolvedRole);
                                  }
                               }
                            } catch (_) {}

                            // Route explicitly based on the dynamic activeRole returned directly by the server API
                            final activeRole = resolvedRole ?? (widget.userRole == 'provider' ? 'professional' : 'user');
                            
                            CustomSnackBar.show(
                              context: context,
                              message: 'Login successful',
                              isError: false,
                            );

                            // Sync FCM token after login
                            NotificationService.instance.getTokenAndSendToBackend(context);

                            if (activeRole == 'professional') {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/provider-bottom-navigation',
                                (route) => false,
                              );
                            } else {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/bottom-navigation',
                                (route) => false,
                              );
                            }
                          }
                        } else {
                          if (mounted) {
                            debugPrint('❌ Login failed: ${signInController.errorMessage}');
                            CustomSnackBar.show(
                              context: context,
                              message:
                                  signInController.errorMessage ??
                                  'Login failed',
                              isError: true,
                            );
                          }
                        }
                      },
                    );
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

                // Social Login Buttons
                Row(
                  children: [
                    Expanded(
                      child: SocialButton(
                        icon: Icons.g_mobiledata,
                        label: 'Google',
                        onTap: () {
                          // TODO: Implement Google login
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: SocialButton(
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
                      debugPrint('➡️ Navigating to Sign Up, clearing controllers');
                      _clearControllers();
                      Navigator.pushNamed(
                        context,
                        '/sign_up',
                        arguments: widget.userRole,
                      );
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
}
