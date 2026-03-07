import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

/// A widget that loads a network image and corrects its EXIF orientation.
class ExifAwareNetworkImage extends StatefulWidget {
  final String url;
  final double height;
  final double width;
  final BoxFit fit;

  const ExifAwareNetworkImage({
    super.key,
    required this.url,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
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
      final response = await http
          .get(Uri.parse(widget.url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Decode and auto-rotate based on EXIF
        final raw = img.decodeImage(response.bodyBytes);
        if (raw != null) {
          // exifOrientation fix: bakeOrientation applies the EXIF rotation
          final fixed = img.bakeOrientation(raw);
          final encoded = Uint8List.fromList(img.encodeJpg(fixed));
          if (mounted) {
            setState(() {
              _imageBytes = encoded;
              _loading = false;
            });
          }
        } else {
          if (mounted)
            setState(() {
              _loading = false;
              _error = true;
            });
        }
      } else {
        if (mounted)
          setState(() {
            _loading = false;
            _error = true;
          });
      }
    } catch (e) {
      debugPrint('ExifAwareNetworkImage error: $e');
      if (mounted)
        setState(() {
          _loading = false;
          _error = true;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: widget.height,
        width: widget.width,
        child: Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black38,
            ),
          ),
        ),
      );
    }

    if (_error || _imageBytes == null) {
      return SizedBox(
        height: widget.height,
        width: widget.width,
        child: Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Image.memory(
        _imageBytes!,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
      ),
    );
  }
}
