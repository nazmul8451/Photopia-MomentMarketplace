import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';
import 'package:photopia/core/widgets/custom_network_image.dart';
import 'package:photopia/core/widgets/my_loader.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DocumentViewerScreen extends StatefulWidget {
  final String urlOrPath;
  final String title;

  const DocumentViewerScreen({
    super.key,
    required this.urlOrPath,
    required this.title,
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  bool _isLoading = true;
  String? _localPath;
  String? _downloadError;

  bool get _isNetwork => widget.urlOrPath.startsWith('http');
  bool get _isPdf => widget.urlOrPath.toLowerCase().endsWith('.pdf');

  @override
  void initState() {
    super.initState();
    if (_isNetwork) {
      _downloadFile();
    } else {
      _localPath = widget.urlOrPath;
      _isLoading = false;
    }
  }

  Future<void> _downloadFile() async {
    setState(() {
      _isLoading = true;
      _downloadError = null;
    });

    try {
      debugPrint("📥 [DocumentViewerScreen] Downloading: ${widget.urlOrPath}");
      
      final String? token = AuthController.accessToken;
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = token.startsWith('Bearer ') ? token : 'Bearer $token';
      }

      final response = await http.get(Uri.parse(widget.urlOrPath), headers: headers);
      
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final fileName = widget.urlOrPath.split('/').last;
        final file = File(p.join(tempDir.path, fileName));
        
        await file.writeAsBytes(response.bodyBytes);
        
        if (mounted) {
          setState(() {
            _localPath = file.path;
            _isLoading = false;
          });
          debugPrint("✅ [DocumentViewerScreen] Saved to: ${_localPath}");
        }
      } else {
        throw "Server returned status code: ${response.statusCode}";
      }
    } catch (e) {
      debugPrint("❌ [DocumentViewerScreen] Download failed: $e");
      if (mounted) {
        setState(() {
          _downloadError = e.toString();
          _isLoading = false;
        });
      }
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
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MyLoader(),
            SizedBox(height: 16.h),
            Text(
              "Preparing document...",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_downloadError != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 50.sp),
              SizedBox(height: 16.h),
              Text(
                "Could not load document",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                _downloadError!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: _downloadFile,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
              TextButton(
                onPressed: () async {
                  final Uri url = Uri.parse(widget.urlOrPath);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text("Open in Browser"),
              ),
            ],
          ),
        ),
      );
    }

    if (_isPdf && _localPath != null) {
      return SfPdfViewer.file(
        File(_localPath!),
        onDocumentLoadFailed: (details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Viewer Error: ${details.description}")),
          );
        },
      );
    }

    if (!_isPdf && _localPath != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: InteractiveViewer(
              child: Image.file(
                File(_localPath!),
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
    }

    return const Center(child: Text("Unknown document type"));
  }
}
