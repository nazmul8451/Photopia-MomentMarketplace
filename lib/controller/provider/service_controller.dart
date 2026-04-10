import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/provider_service_model.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';

class ServiceController extends ChangeNotifier {
  bool _inProgress = false;
  String? _errorMessage;

  // getters
  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;
  List<Data> _myServices = [];
  List<Data> get myServices => _myServices;
  Data? _currentService;
  Data? get currentService => _currentService;
  
  Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => _fieldErrors;

  void clearErrors() {
    _fieldErrors = {};
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> createService(Data serviceData, List<File> images) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? token = AuthController.accessToken;
      // token is already fetched from AuthController above

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

      // Ensure required fields from Zod schema are present
      dataMap['status'] = dataMap['status']?.toString().toLowerCase() != 'inactive' 
          ? "active" 
          : "inactive";
      dataMap['isActive'] = dataMap['isActive'] ?? true;
      dataMap['currency'] = dataMap['currency'] ?? "EUR";
      dataMap['pricingType'] = dataMap['pricingType'] ?? "HOURLY";
      
      if (dataMap['serviceType'] == null || dataMap['serviceType'] == "fixed" || dataMap['serviceType'] == "photography") {
          dataMap['serviceType'] = "hourly"; 
      }
      
      String durationVal = dataMap['duration']?.toString() ?? "1";
      if (!durationVal.toLowerCase().contains("hour")) {
          durationVal = "$durationVal hours";
      }
      dataMap['duration'] = durationVal;

      if (serviceData.category != null) {
        dataMap['category'] = serviceData.category?.sId ?? serviceData.category?.name ?? "";
      }

      if (dataMap['location'] != null) {
        dataMap['location']['type'] = "physical";
        dataMap['location']['address'] = dataMap['location']['address'] ?? "";
      }

      // Ensure pricingModel fields satisfy Zod constraints (dailyHours >= 1)
      if (dataMap['pricingModel'] != null) {
        dataMap['pricingModel']['dailyRate'] = dataMap['pricingModel']['dailyRate'] ?? 1;
        dataMap['pricingModel']['dailyHours'] = dataMap['pricingModel']['dailyHours'] ?? 8;
      } else {
        dataMap['pricingModel'] = {
          "type": dataMap['pricingType'] ?? "HOURLY",
          "dailyRate": 1,
          "dailyHours": 8,
          "packages": []
        };
      }

      // Remove fields that should not be sent for creation
      dataMap.remove('_id');
      dataMap.remove('id');
      dataMap.remove('createdAt');
      dataMap.remove('updatedAt');
      dataMap.remove('__v');
      dataMap.remove('providerId');
      dataMap.remove('gallery'); // Images handled via multipart files
      dataMap.remove('coverMedia'); // Handled via multipart file

      // Add fields
      request.fields['data'] = jsonEncode(dataMap);

      // Add images
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();

        // Use 'images' for all images as an array if the backend expects it
        final String fieldName = 'images';

        final multipartFile = http.MultipartFile(
          fieldName,
          stream,
          length,
          filename: file.path.split(Platform.pathSeparator).last,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      String dataStr = request.fields['data'].toString();
      if (dataStr.length > 500) {
        dataStr = "${dataStr.substring(0, 500)}... [Truncated]";
      }

      debugPrint('🚀 Sending Service Creation Request to ${uri.toString()}');
      debugPrint('📦 Data: $dataStr');
      debugPrint('🖼️ Images: ${images.length}');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamedResponse);

      _inProgress = false;
      debugPrint('📊 Status Code: ${response.statusCode}');
      String respBody = response.body;
      if (respBody.length > 500) {
        respBody = "${respBody.substring(0, 500)}... [Truncated]";
      }
      debugPrint('📦 Body: $respBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        _fieldErrors = {};
        
        // Handle Zod or field-specific errors for better UX
        if (responseBody['errorMessages'] != null && (responseBody['errorMessages'] as List).isNotEmpty) {
          for (var error in responseBody['errorMessages']) {
             final path = error['path']?.toString() ?? 'unknown';
             final msg = error['message']?.toString() ?? 'Error';
             _fieldErrors[path] = msg;
          }
           _errorMessage = "Please fix the errors below";
        } else {
           _errorMessage = responseBody['message'] ?? 'Failed to create service';
        }

        _inProgress = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Create Service Error: $e');
      _inProgress = false;
      if (e.toString().contains('TimeoutException')) {
        _errorMessage = 'Connection timed out. Please check your internet or try again.';
      } else {
        _errorMessage = 'An unexpected error occurred';
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateService(
    String id,
    Data serviceData,
    List<File>? newImages,
  ) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? token = AuthController.accessToken;
      final Uri uri = Uri.parse(Urls.updateService(id));
      final request = http.MultipartRequest('PATCH', uri);

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = token.startsWith('Bearer ')
            ? token
            : 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      final Map<String, dynamic> dataMap = serviceData.toJson();

      // Ensure required update fields are present according to Zod
      dataMap['status'] = serviceData.status?.toLowerCase() != 'inactive' 
          ? "active" 
          : "inactive";
      dataMap['isActive'] = serviceData.isActive ?? true;
      dataMap['isVerified'] = serviceData.isVerified ?? false;
      dataMap['currency'] = dataMap['currency'] ?? "EUR";
      dataMap['pricingType'] = dataMap['pricingType'] ?? "HOURLY";
      
      if (dataMap['serviceType'] == null || dataMap['serviceType'] == "fixed" || dataMap['serviceType'] == "photography") {
          dataMap['serviceType'] = "hourly";
      }
      
      String durationVal = dataMap['duration']?.toString() ?? "1";
      if (!durationVal.toLowerCase().contains("hour")) {
          durationVal = "$durationVal hours";
      }
      dataMap['duration'] = durationVal;

      if (serviceData.category != null) {
        dataMap['category'] = serviceData.category?.sId ?? serviceData.category?.name ?? "";
      }

      if (dataMap['location'] != null) {
        dataMap['location']['type'] = "physical";
        dataMap['location']['address'] = dataMap['location']['address'] ?? "";
      }

      // Ensure pricingModel fields satisfy Zod constraints
      if (dataMap['pricingModel'] != null) {
        dataMap['pricingModel']['dailyRate'] = dataMap['pricingModel']['dailyRate'] ?? 1;
        dataMap['pricingModel']['dailyHours'] = dataMap['pricingModel']['dailyHours'] ?? 8;
      }

      // Format coverMedia as full URL if needed (Zod requires full URL)
      if (dataMap['coverMedia'] != null && dataMap['coverMedia'] is String) {
        String cover = dataMap['coverMedia'];
        if (cover.isNotEmpty && !cover.startsWith('http')) {
          final String base = Urls.baseUrl.endsWith('/') ? Urls.baseUrl.substring(0, Urls.baseUrl.length - 1) : Urls.baseUrl;
          final String path = cover.startsWith('/') ? cover : '/$cover';
          dataMap['coverMedia'] = "$base$path";
        }
      }

      // Format gallery as full URLs if needed (Zod requires full URLs)
      if (serviceData.gallery != null) {
        dataMap['gallery'] = serviceData.gallery!.map((img) {
          if (img is String && !img.startsWith('http')) {
            final String base = Urls.baseUrl.endsWith('/') ? Urls.baseUrl.substring(0, Urls.baseUrl.length - 1) : Urls.baseUrl;
            final String path = img.startsWith('/') ? img : '/$img';
            return "$base$path";
          }
          return img;
        }).toList();
      }

      // Remove fields that should not be sent for update
      dataMap.remove('_id');
      dataMap.remove('id');
      dataMap.remove('createdAt');
      dataMap.remove('updatedAt');
      dataMap.remove('__v');
      dataMap.remove('providerId');

      request.fields['data'] = jsonEncode(dataMap);

      // Add new images if provided
      if (newImages != null && newImages.isNotEmpty) {
        for (var file in newImages) {
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();

          // Reverted to 'images' based on Multer 500 Unexpected field error
          final String fieldName = 'images';

          final multipartFile = http.MultipartFile(
            fieldName,
            stream,
            length,
            filename: file.path.split('/').last,
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(multipartFile);
        }
      }

      String dataStr = request.fields['data'].toString();
      if (dataStr.length > 500) {
        dataStr = "${dataStr.substring(0, 500)}... [Truncated]";
      }

      debugPrint('🚀 Sending Service Update Request to ${uri.toString()}');
      debugPrint('📦 Data: $dataStr');
      debugPrint('🖼️ New Images: ${newImages?.length ?? 0}');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamedResponse);

      _inProgress = false;
      debugPrint('📊 Update Status Code: ${response.statusCode}');
      String respBody = response.body;
      if (respBody.length > 500) {
        respBody = "${respBody.substring(0, 500)}... [Truncated]";
      }
      debugPrint('📦 Update Body: $respBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        _fieldErrors = {};

        // Handle Zod or field-specific errors for better UX
        if (responseBody['errorMessages'] != null && (responseBody['errorMessages'] as List).isNotEmpty) {
          for (var error in responseBody['errorMessages']) {
             final path = error['path']?.toString() ?? 'unknown';
             final msg = error['message']?.toString() ?? 'Error';
             _fieldErrors[path] = msg;
          }
          _errorMessage = "Please fix the errors below";
        } else {
           _errorMessage = responseBody['message'] ?? 'Failed to update service';
        }

        _inProgress = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Update Service Error: $e');
      _inProgress = false;
      if (e.toString().contains('TimeoutException')) {
        _errorMessage = 'Connection timed out. Please check your internet or try again.';
      } else {
        _errorMessage = 'An unexpected error occurred';
      }
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
        final dynamic rawData = response.body?['data'];
        List<dynamic> listData = [];

        if (rawData is Map && rawData.containsKey('data')) {
          listData = rawData['data'] as List<dynamic>;
        } else if (rawData is List) {
          listData = rawData;
        }

        if (listData.isNotEmpty) {
          debugPrint('✅ Fetched ${listData.length} categories from API');
        }
        return listData.map((json) => Category.fromJson(json)).toList();
      }

      debugPrint(
        '⚠️ API Response for categories: ${response.statusCode} - ${response.body}',
      );
      debugPrint('No categories from API or API failed, using fallback');
    } catch (e) {
      debugPrint('Get Categories Exception: $e');
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

  Future<bool> deleteService(String id) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await NetworkCaller.deleteRequest(
        url: Urls.deleteService(id),
      );

      _inProgress = false;
      if (response.isSuccess) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to delete service";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _inProgress = false;
      _errorMessage = "An unexpected error occurred";
      notifyListeners();
      debugPrint("Delete Service Error: $e");
      return false;
    }
  }

  Future<bool> getMyServices() async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final NetworkResponse response = await NetworkCaller.getRequest(
        url: Urls.myListingApi,
        requireAuth: true,
      );

      _inProgress = false;
      if (response.isSuccess && response.body != null) {
        final listModel = ProviderServiceListModel.fromJson(response.body!);
        _myServices = listModel.data ?? [];
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to fetch services';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _inProgress = false;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> getSingleService(String id) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final NetworkResponse response = await NetworkCaller.getRequest(
        url: Urls.getSingleList(id),
        requireAuth: true,
      );

      _inProgress = false;
      if (response.isSuccess && response.body != null) {
        final model = ProviderServiceModel.fromJson(response.body!);
        _currentService = model.data;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            response.errorMessage ?? 'Failed to fetch service details';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _inProgress = false;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleServiceStatus(String id, String status) async {
    _inProgress = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final NetworkResponse response = await NetworkCaller.patchRequest(
        url: Urls.toggleServiceStatus(id),
        body: {'status': status},
        requireAuth: true,
      );

      _inProgress = false;
      if (response.isSuccess) {
        // Update local list if it exists
        final index = _myServices.indexWhere((s) => s.id == id || s.sId == id);
        if (index != -1) {
          _myServices[index].status = status;
        }
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to update status';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _inProgress = false;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _myServices = [];
    _currentService = null;
    _fieldErrors = {};
    _errorMessage = null;
    _inProgress = false;
    notifyListeners();
  }
}
