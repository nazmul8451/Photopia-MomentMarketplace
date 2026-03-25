import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/network/urls.dart';

class NetworkResponse {
  final bool isSuccess;
  final String? errorMessage;
  final int statusCode;
  final Map<String, dynamic>? body;
  final List<int>? bodyBytes;

  NetworkResponse({
    required this.isSuccess,
    required this.statusCode,
    this.body,
    this.bodyBytes,
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
    
    // Always prioritize AuthController.accessToken, then GetStorage()
    if (tokenToUse == null || tokenToUse.isEmpty) {
      if (requireAuth) {
        tokenToUse = AuthController.accessToken ?? GetStorage().read('user_token');
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
      debugPrint("🔐 Auth token added to headers: ${tokenToUse.substring(0, 5)}...");
    }
    
    return headers;
  }

  // Unified response handling
  static NetworkResponse _handleResponse(
    Response response,
    String url,
    String method, {
    bool isRaw = false,
  }) {
    _logResponse(method, url, response);

    final int statusCode = response.statusCode;
    Map<String, dynamic>? decodedBody;

    // For errors, always try to decode the body to get the message, even if isRaw is true
    if (!isRaw || statusCode >= 400) {
      try {
        if (response.body.isNotEmpty) {
          decodedBody = jsonDecode(response.body);
        }
      } catch (e) {
        debugPrint("Error decoding response body: $e");
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return NetworkResponse(
        isSuccess: true,
        statusCode: statusCode,
        body: decodedBody,
        bodyBytes: isRaw ? response.bodyBytes : null,
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

  // ─── Refresh Token ────────────────────────────────────────────────────────

  /// Attempts to refresh the access token using the stored cookie.
  /// Returns true if successful.
  static Future<bool> _refreshAccessToken() async {
    final cookie = AuthController.refreshTokenCookie;
    if (cookie == null || cookie.isEmpty) {
      debugPrint('🔴 No refresh cookie stored. Cannot refresh token.');
      return false;
    }
    try {
      final uri = Uri.parse(Urls.refreshToken);
      final response = await get(uri, headers: {
        'Accept': 'application/json',
        'Cookie': cookie,
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final newToken = body['data']?['accessToken'];
        if (newToken != null) {
          await AuthController.saveUserToken(newToken);
          debugPrint('✅ Token refreshed successfully.');

          // If user was in professional mode, re-switch role
          // because the refreshed token may default to client role
          final storedRole = AuthController.activeRole;
          if (storedRole == 'professional') {
            debugPrint('🔄 Re-applying professional role after token refresh...');
            try {
              final roleUri = Uri.parse(Urls.role);
              final roleHeaders = await _getHeaders(requireAuth: true);
              await patch(
                roleUri,
                headers: roleHeaders,
                body: jsonEncode({'role': 'professional'}),
              ).timeout(const Duration(seconds: 10));
              debugPrint('✅ Role re-applied: professional');
            } catch (e) {
              debugPrint('⚠️ Role re-apply failed: $e');
            }
          }

          return true;
        }
      }
    } catch (e) {
      debugPrint('🔴 Token refresh error: $e');
    }
    return false;
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

      final Response response = await get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 401 && requireAuth) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          // Retry with new token
          final retryHeaders = await _getHeaders(requireAuth: requireAuth);
          final retryResponse = await get(uri, headers: retryHeaders)
              .timeout(const Duration(seconds: 15));
          return _handleResponse(retryResponse, url, 'GET');
        } else {
          await AuthController.forceLogout();
          return NetworkResponse(
            isSuccess: false,
            statusCode: 401,
            errorMessage: _unAuthorizedErrorMessage,
          );
        }
      } else if (response.statusCode == 403 && requireAuth) {
        final reApplied = await _reApplyProfessionalRole();
        if (reApplied) {
          final retryHeaders = await _getHeaders(requireAuth: requireAuth);
          final retryResponse = await get(uri, headers: retryHeaders)
              .timeout(const Duration(seconds: 15));
          return _handleResponse(retryResponse, url, 'GET');
        }
      }
      return _handleResponse(response, url, 'GET');
    } catch (e) {
      debugPrint('GET request error: $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  // GET Raw Request (for binary files)
  static Future<NetworkResponse> getRequestRaw({
    required String url,
    String? token,
    bool requireAuth = true,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      
      // For binary files, we don't want Content-Type: application/json
      final Map<String, String> headers = {};
      
      String? tokenToUse = token ?? AuthController.accessToken;
      if (tokenToUse == null || tokenToUse.isEmpty) {
        tokenToUse = GetStorage().read('user_token');
      }

      if (tokenToUse != null && tokenToUse.isNotEmpty) {
        headers['Authorization'] = tokenToUse.startsWith('Bearer ')
            ? tokenToUse
            : 'Bearer $tokenToUse';
      }

      final Response response = await get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 401 && requireAuth) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          final retryToken = AuthController.accessToken;
          final Map<String, String> retryHeaders = {};
          if (retryToken != null) {
            retryHeaders['Authorization'] = retryToken.startsWith('Bearer ')
                ? retryToken
                : 'Bearer $retryToken';
          }
          final retryResponse = await get(uri, headers: retryHeaders)
              .timeout(const Duration(seconds: 30));
          return _handleResponse(retryResponse, url, 'GET', isRaw: true);
        } else {
          await AuthController.forceLogout();
          return NetworkResponse(
            isSuccess: false,
            statusCode: 401,
            errorMessage: _unAuthorizedErrorMessage,
          );
        }
      } else if (response.statusCode == 403 && requireAuth) {
        final reApplied = await _reApplyProfessionalRole();
        if (reApplied) {
          final retryToken = AuthController.accessToken;
          final Map<String, String> retryHeaders = {};
          if (retryToken != null) {
            retryHeaders['Authorization'] = retryToken.startsWith('Bearer ')
                ? retryToken
                : 'Bearer $retryToken';
          }
          final retryResponse = await get(uri, headers: retryHeaders)
              .timeout(const Duration(seconds: 30));
          return _handleResponse(retryResponse, url, 'GET', isRaw: true);
        }
      }
      return _handleResponse(response, url, 'GET', isRaw: true);
    } catch (e) {
      debugPrint('GET RAW request error: $e');
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
    String? cookie,
    bool addBearer = true,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      final Map<String, String> headers = await _getHeaders(
        requireAuth: requireAuth,
        token: token,
        addBearer: addBearer,
      );

      if (cookie != null && cookie.isNotEmpty) {
        headers['Cookie'] = cookie;
      }

      _logRequest('POST', url, body ?? {}, headers);

      final Response response = await post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 401 && requireAuth) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          final retryHeaders = await _getHeaders(requireAuth: requireAuth);
          final retryResponse = await post(uri,
              headers: retryHeaders, body: body != null ? jsonEncode(body) : null);
          return _handleResponse(retryResponse, url, 'POST');
        } else {
          await AuthController.forceLogout();
          return NetworkResponse(
            isSuccess: false,
            statusCode: 401,
            errorMessage: _unAuthorizedErrorMessage,
          );
        }
      } else if (response.statusCode == 403 && requireAuth) {
        final reApplied = await _reApplyProfessionalRole();
        if (reApplied) {
          final retryHeaders = await _getHeaders(requireAuth: requireAuth);
          final retryResponse = await post(uri,
              headers: retryHeaders, body: body != null ? jsonEncode(body) : null);
          return _handleResponse(retryResponse, url, 'POST');
        }
      }
      return _handleResponse(response, url, 'POST');
    } catch (e) {
      debugPrint('POST request error: $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  // PATCH Request (JSON body, no file)
  static Future<NetworkResponse> patchRequest({
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

      _logRequest('PATCH', url, body ?? {}, headers);

      final Response response = await patch(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 401 && requireAuth) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          final retryHeaders = await _getHeaders(requireAuth: requireAuth);
          final retryResponse = await patch(uri,
              headers: retryHeaders, body: body != null ? jsonEncode(body) : null);
          return _handleResponse(retryResponse, url, 'PATCH');
        } else {
          await AuthController.forceLogout();
          return NetworkResponse(
            isSuccess: false,
            statusCode: 401,
            errorMessage: _unAuthorizedErrorMessage,
          );
        }
      } else if (response.statusCode == 403 && requireAuth) {
        final reApplied = await _reApplyProfessionalRole();
        if (reApplied) {
          final retryHeaders = await _getHeaders(requireAuth: requireAuth);
          final retryResponse = await patch(uri,
              headers: retryHeaders, body: body != null ? jsonEncode(body) : null);
          return _handleResponse(retryResponse, url, 'PATCH');
        }
      }
      return _handleResponse(response, url, 'PATCH');
    } catch (e) {
      debugPrint('PATCH request error: $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  // DELETE Request
  static Future<NetworkResponse> deleteRequest({
    required String url,
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

      _logRequest('DELETE', url, {}, headers);

      final Response response = await delete(uri, headers: headers);

      if (response.statusCode == 401 && requireAuth) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          final retryHeaders = await _getHeaders(requireAuth: requireAuth);
          final retryResponse = await delete(uri, headers: retryHeaders);
          return _handleResponse(retryResponse, url, 'DELETE');
        } else {
          await AuthController.forceLogout();
          return NetworkResponse(
            isSuccess: false,
            statusCode: 401,
            errorMessage: _unAuthorizedErrorMessage,
          );
        }
      } else if (response.statusCode == 403 && requireAuth) {
        final reApplied = await _reApplyProfessionalRole();
        if (reApplied) {
          final retryHeaders = await _getHeaders(requireAuth: requireAuth);
          final retryResponse = await delete(uri, headers: retryHeaders);
          return _handleResponse(retryResponse, url, 'DELETE');
        }
      }
      return _handleResponse(response, url, 'DELETE');
    } catch (e) {
      debugPrint('DELETE request error: $e');
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<NetworkResponse> multipartRequest({
    String? token,
    required String url,
    required String method,
    Map<String, String>? fields,
    String? fileKey,
    String? filePath,
    bool requireAuth = true,
  }) async {
    try {
      final Uri uri = Uri.parse(url);

      final request = MultipartRequest(method, uri);

      // Add ONLY auth headers — NOT Content-Type.
      // The http package sets Content-Type: multipart/form-data with boundary automatically.
      // If we set Content-Type: application/json here, it will break the multipart boundary.
      String? tokenToUse = token ?? AuthController.accessToken;
      if (tokenToUse == null || tokenToUse.isEmpty) {
        tokenToUse = GetStorage().read('user_token');
      }
      if (tokenToUse != null && tokenToUse.isNotEmpty) {
        request.headers['Authorization'] = tokenToUse.startsWith('Bearer ')
            ? tokenToUse
            : 'Bearer $tokenToUse';
      }
      request.headers['Accept'] = 'application/json';

      // Add text fields if any
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add file if fileKey and filePath are provided
      if (filePath != null && filePath.isNotEmpty && fileKey != null) {
        request.files.add(
          await MultipartFile.fromPath(
            fileKey,
            filePath,
            contentType: MediaType(
              'image',
              'jpeg',
            ), // Adding this is crucial for Node.js backends
          ),
        );
      }

      _logRequest(method, url, fields ?? {}, request.headers);

      // Send the request with a timeout
      final StreamedResponse streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );

      // Convert StreamedResponse to Response to use the existing _handleResponse method
      final Response response = await Response.fromStream(streamedResponse);

      if (response.statusCode == 401 && requireAuth) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          // Retry logic for multipart would be complex, but let's at least log it
          // OR we could call the method again if we had the original arguments
          debugPrint('🔄 Token refreshed during multipart. Please retry upload.');
        } else {
          await AuthController.forceLogout();
        }
      } else if (response.statusCode == 403 && requireAuth) {
        final reApplied = await _reApplyProfessionalRole();
        if (reApplied) {
          debugPrint('🔄 Role re-applied during multipart. Please retry upload.');
        }
      }

      return _handleResponse(response, url, method);
    } catch (e) {
      debugPrint("Multipart request error: $e");
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
  /// Specifically for handling 403 Forbidden by re-syncing the professional role
  static Future<bool> _reApplyProfessionalRole() async {
    final storedRole = AuthController.activeRole ?? GetStorage().read('active_role');
    if (storedRole == 'professional') {
      debugPrint('🔄 403 Detected. Re-applying professional role...');
      try {
        final roleUri = Uri.parse(Urls.role);
        final roleHeaders = await _getHeaders(requireAuth: true);
        final response = await patch(
          roleUri,
          headers: roleHeaders,
          body: jsonEncode({'role': 'professional'}),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final newToken = body['data']?['accessToken'];
          if (newToken != null) {
            await AuthController.saveUserToken(newToken);
            debugPrint('✅ New token captured and saved after role re-apply');
          }
          debugPrint('✅ Professional role re-applied successfully after 403');
          return true;
        } else {
          debugPrint('⚠️ Role re-apply failed with status: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('⚠️ Role re-apply error: $e');
      }
    }
    return false;
  }
}
