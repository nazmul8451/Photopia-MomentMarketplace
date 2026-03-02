class Urls {
  static const String baseUrl = 'http://10.10.7.50:4003';
  //authentication API
  static const String signUp = '$baseUrl/api/v1/auth/signup';
  static const String signIn = '$baseUrl/api/v1/auth/login';
  static const String logOut = '$baseUrl/api/v1/auth/logout';
  static const String verifyOtp = '$baseUrl/api/v1/auth/verify-account';
}
