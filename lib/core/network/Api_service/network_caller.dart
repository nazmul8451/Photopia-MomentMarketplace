import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';

import 'dart:convert';

class NetworkResponse {
  final bool issSuccess;
  final String? errorMessage;
  final int statusCode;
  final Map<String, dynamic>? body;

  NetworkResponse({
    required this.issSuccess,
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
  // Resolve token from AuthController or secure storage

  // Centralized header management
  static Future<Map<String, String>> _getHeaders({
    bool requireAuth = true,
    String? token,
  }) async {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = token.contains(".")
          ? 'Bearer $token'
          : 'Bearer $token';
      debugPrint("Auth token added from parameter.");
    } else if (requireAuth) {
      const storage = FlutterSecureStorage();
      final String? storedToken = await storage.read(key: 'access_token');
      if (storedToken != null && storedToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $storedToken';
        debugPrint("Auth token added from secure storage.");
      }
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
        issSuccess: true,
        statusCode: statusCode,
        body: decodedBody,
      );
    } else if (statusCode == 401) {
      return NetworkResponse(
        issSuccess: false,
        statusCode: statusCode,
        errorMessage: _unAuthorizedErrorMessage,
        body: decodedBody,
      );
    } else {
      return NetworkResponse(
        issSuccess: false,
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
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      final Map<String, String> headers = await _getHeaders(
        requireAuth: requireAuth,
        token: token,
      );

      final Response response = await get(uri, headers: headers);
      return _handleResponse(response, url, "GET");
    } catch (e) {
      debugPrint("GET request error: $e");
      return NetworkResponse(
        issSuccess: false,
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
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      final Map<String, String> headers = await _getHeaders(
        requireAuth: requireAuth,
        token: token,
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
        issSuccess: false,
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
    debugPrint('� Headers: $headers');
    debugPrint('� Body: $body');
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
