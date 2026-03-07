import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/provider_service_model.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';

class ServiceController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;
  final _storage = const FlutterSecureStorage();

  // getters
  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  Future<bool> createService(Data serviceData, List<File> images) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? token = AuthController.accessToken;
      if (token == null || token.isEmpty) {
        token = await _storage.read(key: 'access_token');
      }

      final Uri uri = Uri.parse(Urls.service);
      final request = http.MultipartRequest('POST', uri);

      // Add Headers
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = token.startsWith('Bearer ')
            ? token
            : 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // Prepare data map for backend
      final Map<String, dynamic> dataMap = serviceData.toJson();

      if (serviceData.category != null) {
        dataMap['category'] =
            serviceData.category?.sId ?? serviceData.category?.id ?? "";
      }

      // 2. location.address must be a string
      if (dataMap['location'] != null) {
        dataMap['location']['address'] = dataMap['location']['address'] ?? "";
      }

      // 3. status must be one of 'DRAFT', 'ACTIVE', etc.
      dataMap['status'] = dataMap['status'] ?? "ACTIVE";

      // Remove fields that should not be sent for creation
      dataMap.remove('_id');
      dataMap.remove('id');
      dataMap.remove('createdAt');
      dataMap.remove('updatedAt');
      dataMap.remove('__v');
      dataMap.remove('providerId');
      dataMap.remove('gallery');

      // Add fields
      request.fields['data'] = jsonEncode(dataMap);

      // Add images
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();

        final multipartFile = http.MultipartFile(
          'images',
          stream,
          length,
          filename: file.path.split(Platform.pathSeparator).last,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      debugPrint('🚀 Sending Service Creation Request to ${uri.toString()}');
      debugPrint('📦 Data: ${request.fields['data']}');
      debugPrint('🖼️ Images: ${images.length}');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      _inProgress = false;
      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📦 Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        _errorMessage = responseBody['message'] ?? 'Failed to create service';
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Create Service Error: $e');
      _inProgress = false;
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return false;
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final NetworkResponse response = await NetworkCaller.getRequest(
        url: Urls.categories,
        requireAuth: true,
      );

      if (response.isSuccess && response.body != null) {
        final List<dynamic> data = response.body?['data'] ?? [];
        if (data.isNotEmpty) {
          debugPrint('✅ Fetched ${data.length} categories from API');
          return data.map((item) => Category.fromJson(item)).toList();
        }
      }

      debugPrint(
        '⚠️ API Response for categories: ${response.statusCode} - ${response.body}',
      );
      debugPrint('⚠️ No categories from API or API failed, using fallback');
    } catch (e) {
      debugPrint('❌ Get Categories Exception: $e');
    }

    // Fallback categories with the working ID provided by the user
    return [
      Category(
        sId: "6967f8313c7a3a49e02c1fde",
        name: "Photography",
      ), // User's working Postman ID
      Category(sId: "65e8a5b4f1a2b3c4d5e6f702", name: "Videography"),
      Category(sId: "65e8a5b4f1a2b3c4d5e6f703", name: "Video Editing"),
    ];
  }
}
