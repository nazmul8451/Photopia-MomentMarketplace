class Urls {
  static const String baseUrl = 'http://10.10.7.50:4003';
  //authentication API
  static const String signUp = '$baseUrl/api/v1/auth/signup';
  static const String signIn = '$baseUrl/api/v1/auth/login';
  static const String logOut = '$baseUrl/api/v1/auth/logout';
  static const String verifyOtp = '$baseUrl/api/v1/auth/verify-account';
  static const String forgotPassword = '$baseUrl/api/v1/auth/forget-password';
  static const String resetPassword = '$baseUrl/api/v1/auth/reset-password';
  //user profile api
  static const String userProfile = '$baseUrl/api/v1/users/profile';
  static const String updateUserProfile = '$baseUrl/api/v1/user/profile';//PATCH
}
