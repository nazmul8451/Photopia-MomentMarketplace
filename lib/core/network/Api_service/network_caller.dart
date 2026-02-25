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

  // static Future<String?> _getToken() async {
  //   final storage = const FlutterSecureStorage();
  //   final tokenFromController = AuthController().accessToken;
  //   if (tokenFromController != null && tokenFromController.isNotEmpty)
  //     return tokenFromController;
  //   return await storage.read(key: 'access_token');
  // }

  //get request for api call
  static Future<NetworkResponse> getRequest({
    required String url,
    String? token,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      final Map<String, String> headers = {'Accept': "application/json"};

      final Response response = await get(uri, headers: headers);
      _logResponse("GET", url, response);
      if (response.statusCode == 200) {
        final decodeJson = jsonDecode(response.body);
        return NetworkResponse(
          issSuccess: true,
          statusCode: response.statusCode,
          body: decodeJson,
        );
      } else if (response.statusCode == 401) {
        final decodeJson = jsonDecode(response.body);
        return NetworkResponse(
          issSuccess: false,
          errorMessage: _unAuthorizedErrorMessage,
          statusCode: response.statusCode,
        );
      } else {
        final decodeJson = jsonDecode(response.body);
        return NetworkResponse(
          issSuccess: false,
          statusCode: response.statusCode,
          errorMessage: decodeJson['message'] ?? _defaultErrorMessage,
        );
      }
    } catch (e) {
      return NetworkResponse(
        issSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  // post Request for api post call
  static Future<NetworkResponse> postRequest({
    
    required String url,
    Map<String, dynamic>? body,
    bool requireAuth = true,
    bool isFromLogin = false,
    String? token,

  }) async {
    try {
      final Uri uri = Uri.parse(url);
      final Map<String, String> headers = {'Accept': 'application/json'};
      // _logRequest("POST", url,, headers)

      //handle Authorization token
      // if(token!=null && token.isNotEmpty){
      //   if(token.contains(".")){
      //     headers['Authorization'] = 'Bearer $token';
      //     debugPrint("JWT TOKEN ADDED :  $token");

      //   }else{
      //     headers['Authorization']  = token;
      //     headers['token'] = token;
      //     debugPrint("TOKEN ADDED :  $token");
      //   }
      // }else if(requireAuth ){
      //   // final String? token = await
      // }
    } catch (e) {}
  }

  //debug print classs

  static void _logRequest(
    String method,
    String url,
    Map<String, dynamic> body,
    Map<String, String> headers,
  ) {
    debugPrint('🚀 ===== $method API Request ===== 🚀');
    debugPrint('🌐 URL: $url');
    debugPrint('📦 Body: $body');
    debugPrint('📤 Headers: $headers');
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
