import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  static const String name = '/privacy_policy';
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _isLoading = true;
  String? _content;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPrivacyPolicy();
  }

  Future<void> _fetchPrivacyPolicy() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.getPrivacyPolicy,
      );
      if (response.isSuccess && response.body != null) {
        setState(() {
          _content = response.body!['data']['content'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              response.errorMessage ?? "Failed to load privacy policy";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: _fetchPrivacyPolicy,
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Text(
                _content ?? "No content available",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ),
    );
  }
}
