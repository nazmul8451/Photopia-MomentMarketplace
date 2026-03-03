import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:photopia/controller/auth_controller.dart';

class NetworkResponse {
  final bool isSuccess;
  final String? errorMessage;
  final int statusCode;
  final Map<String, dynamic>? body;

  NetworkResponse({
    required this.isSuccess,
    required this.statusCode,
    this.body,
    this.errorMessage,
  });
}

class NetworkCaller {
  //API Caller Class

  //logical message
  static const String _defaultErrorMessage =
      "Something went wrong. Please try again later.";
  static const String _unAuthorizedErrorMessage =
      "You are not authorized to access this resource.";

  // Centralized header management
  static Future<Map<String, String>> _getHeaders({
    bool requireAuth = true,
    String? token,
    bool addBearer = true,
  }) async {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    String? tokenToUse = token;

    if (tokenToUse == null || tokenToUse.isEmpty) {
      if (requireAuth) {
        tokenToUse = AuthController.accessToken;
        if (tokenToUse == null || tokenToUse.isEmpty) {
          const storage = FlutterSecureStorage();
          tokenToUse = await storage.read(key: 'access_token');
        }
      }
    }

    if (tokenToUse != null && tokenToUse.isNotEmpty) {
      if (addBearer) {
        if (!tokenToUse.startsWith('Bearer ')) {
          headers['Authorization'] = 'Bearer $tokenToUse';
        } else {
          headers['Authorization'] = tokenToUse;
        }
      } else {
        // Remove Bearer if it's there but addBearer is false
        if (tokenToUse.startsWith('Bearer ')) {
          headers['Authorization'] = tokenToUse.replaceFirst('Bearer ', '');
        } else {
          headers['Authorization'] = tokenToUse;
        }
      }
      debugPrint("Auth token added to headers.");
    }
    return headers;
  }

  // Unified response handling
  static NetworkResponse _handleResponse(
    Response response,
    String url,
    String method,
  ) {
    _logResponse(method, url, response);

    final int statusCode = response.statusCode;
    Map<String, dynamic>? decodedBody;

    try {
      if (response.body.isNotEmpty) {
        decodedBody = jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Error decoding response body: $e");
    }

    if (statusCode >= 200 && statusCode < 300) {
      return NetworkResponse(
        isSuccess: true,
        statusCode: statusCode,
        body: decodedBody,
      );
    } else if (statusCode == 401) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: statusCode,
        errorMessage: _unAuthorizedErrorMessage,
        body: decodedBody,
      );
    } else {
      return NetworkResponse(
        isSuccess: false,
        statusCode: statusCode,
        errorMessage: decodedBody?['message'] ?? _defaultErrorMessage,
        body: decodedBody,
      );
    }
  }

  // GET Request
  static Future<NetworkResponse> getRequest({
    required String url,
    String? token,
    bool requireAuth = true,
    bool addBearer = true,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      final Map<String, String> headers = await _getHeaders(
        requireAuth: requireAuth,
        token: token,
        addBearer: addBearer,
      );

      final Response response = await get(uri, headers: headers);
      return _handleResponse(response, url, "GET");
    } catch (e) {
      debugPrint("GET request error: $e");
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  // POST Request
  static Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
    bool requireAuth = true,
    String? token,
    bool addBearer = true,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      final Map<String, String> headers = await _getHeaders(
        requireAuth: requireAuth,
        token: token,
        addBearer: addBearer,
      );

      _logRequest("POST", url, body ?? {}, headers);

      final Response response = await post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response, url, "POST");
    } catch (e) {
      debugPrint("POST request error: $e");
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  // Logging
  static void _logRequest(
    String method,
    String url,
    Map<String, dynamic> body,
    Map<String, String> headers,
  ) {
    debugPrint('🚀 ===== $method API Request ===== 🚀');
    debugPrint('🌐 URL: $url');
    debugPrint(' Headers: $headers');
    debugPrint(' Body: $body');
    debugPrint('====================================');
  }

  static void _logResponse(String method, String url, Response response) {
    debugPrint('🚀 ===== $method API Response ===== 🚀');
    debugPrint('🌐 URL: $url');
    debugPrint('📊 Status Code: ${response.statusCode}');
    debugPrint('📦 Response Body: ${response.body}');
    debugPrint('====================================');
  }
}
