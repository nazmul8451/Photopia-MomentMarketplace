class StripeConnectStatusResponse {
  final int statusCode;
  final bool success;
  final String message;
  final StripeConnectStatus data;

  StripeConnectStatusResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory StripeConnectStatusResponse.fromJson(Map<String, dynamic> json) {
    return StripeConnectStatusResponse(
      statusCode: json['statusCode'] ?? 0,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: StripeConnectStatus.fromJson(json['data'] ?? {}),
    );
  }
}

class StripeConnectStatus {
  final bool isComplete;
  final bool detailsSubmitted;
  final bool chargesEnabled;
  final bool payoutsEnabled;

  StripeConnectStatus({
    required this.isComplete,
    required this.detailsSubmitted,
    this.chargesEnabled = false,
    this.payoutsEnabled = false,
  });

  factory StripeConnectStatus.fromJson(Map<String, dynamic> json) {
    return StripeConnectStatus(
      isComplete: json['isComplete'] ?? false,
      detailsSubmitted: json['detailsSubmitted'] ?? false,
      chargesEnabled: json['chargesEnabled'] ?? false,
      payoutsEnabled: json['payoutsEnabled'] ?? false,
    );
  }
}

class StripeOnboardingResponse {
  final int statusCode;
  final bool success;
  final String message;
  final StripeOnboardingData data;

  StripeOnboardingResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory StripeOnboardingResponse.fromJson(Map<String, dynamic> json) {
    return StripeOnboardingResponse(
      statusCode: json['statusCode'] ?? 0,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: StripeOnboardingData.fromJson(json['data'] ?? {}),
    );
  }
}

class StripeOnboardingData {
  final String url;

  StripeOnboardingData({required this.url});

  factory StripeOnboardingData.fromJson(Map<String, dynamic> json) {
    return StripeOnboardingData(url: json['url'] ?? '');
  }
}
