import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/network/urls.dart';

/// A widget that loads a profile image using the Bearer token
/// so that auth-protected image endpoints can be correctly fetched.
class AuthProfileImage extends StatefulWidget {
  final String? imageUrl;
  final double size;

  const AuthProfileImage({
    super.key,
    required this.imageUrl,
    required this.size,
  });

  @override
  State<AuthProfileImage> createState() => _AuthProfileImageState();
}

class _AuthProfileImageState extends State<AuthProfileImage> {
  Uint8List? _imageBytes;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

  @override
  void didUpdateWidget(AuthProfileImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _fetchImage();
    }
  }

  Future<void> _fetchImage() async {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final String? token = AuthController.accessToken ?? GetStorage().read('user_token');

      final String baseFullUrl = widget.imageUrl!.startsWith('http')
          ? widget.imageUrl!
          : '${Urls.baseUrl}${widget.imageUrl}';

      // Bypass cache by appending timestamp
      final String fullUrl =
          '$baseFullUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {
          'Accept': 'image/*',
          if (token != null && token.isNotEmpty)
            'Authorization': token.startsWith('Bearer ')
                ? token
                : 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _imageBytes = response.bodyBytes;
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: ClipOval(
        child: _loading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : _hasError || _imageBytes == null
            ? Icon(
                Icons.person,
                size: widget.size * 0.5,
                color: Colors.grey.shade400,
              )
            : Image.memory(_imageBytes!, fit: BoxFit.cover),
      ),
    );
  }
}
