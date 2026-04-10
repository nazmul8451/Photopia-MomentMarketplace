import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shimmer/shimmer.dart';

class ExifAwareNetworkImage extends StatefulWidget {
  final String url;
  final double height;
  final double width;
  final BoxFit fit;
  final Map<String, String>? headers;

  const ExifAwareNetworkImage({
    super.key,
    required this.url,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
    this.headers,
  });

  @override
  State<ExifAwareNetworkImage> createState() => _ExifAwareNetworkImageState();
}

class _ExifAwareNetworkImageState extends State<ExifAwareNetworkImage> {
  Uint8List? _imageBytes;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ExifAwareNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = false;
      _imageBytes = null;
    });

    try {
      final String? token =
          AuthController.accessToken ?? GetStorage().read('user_token');
      Map<String, String> requestHeaders = {
        if (token != null)
          'Authorization': token.startsWith('Bearer ')
              ? token
              : 'Bearer $token',
      };
      if (widget.headers != null) {
        requestHeaders.addAll(widget.headers!);
      }

      final response = await http
          .get(Uri.parse(widget.url), headers: requestHeaders)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        Uint8List bytes = response.bodyBytes;

        try {
          // Native rotation fix using flutter_image_compress
          var result = await FlutterImageCompress.compressWithList(
            bytes,
            quality: 95,
            rotate: 0, // Auto-rotate based on EXIF
            keepExif: false,
          );
          bytes = Uint8List.fromList(result);
        } catch (e) {
          debugPrint("Orientation fix error: $e");
        }

        if (mounted) {
          setState(() {
            _imageBytes = bytes;
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _error = true);
      }
    } catch (e) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: widget.height,
          width: widget.width,
          color: Colors.white,
        ),
      );
    }

    if (_error || _imageBytes == null) {
      return SizedBox(
        height: widget.height,
        width: widget.width,
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }

    return Image.memory(
      _imageBytes!,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
    );
  }
}
