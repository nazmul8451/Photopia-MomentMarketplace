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
