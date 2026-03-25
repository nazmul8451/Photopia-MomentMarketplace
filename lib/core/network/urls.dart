class Urls {
  static const String baseUrl = 'http://10.10.7.50:4003';
  //authentication API
  static const String signUp = '$baseUrl/api/v1/auth/signup';
  static const String signIn = '$baseUrl/api/v1/auth/login';
  static const String logOut = '$baseUrl/api/v1/auth/logout';
  static const String refreshToken = '$baseUrl/api/v1/auth/refresh-token';
  static const String verifyOtp = '$baseUrl/api/v1/auth/verify-account';
  static const String forgotPassword = '$baseUrl/api/v1/auth/forget-password';
  static const String resetPassword = '$baseUrl/api/v1/auth/reset-password';
  //user profile api
  static const String userProfile = '$baseUrl/api/v1/users/profile';
  static String getUserById(String id) => '$baseUrl/api/v1/users/$id';
  static const String updateUserProfile =
      '$baseUrl/api/v1/users/profile'; // PATCH FOR UPDATE PROFILE

  //Role api
  static const String role = '$baseUrl/api/v1/users/switch-role';

  //provider

  //** serivce api */
  static const String service = '$baseUrl/api/v1/services';
  static String updateService(String id) => '$baseUrl/api/v1/services/$id';
  static String deleteService(String id) => '$baseUrl/api/v1/services/$id';
  static String toggleServiceStatus(String id) => '$baseUrl/api/v1/services/$id/status';
  static String getServicesByProvider(String providerId) => '$baseUrl/api/v1/services/provider/$providerId';
  //Calender and availibility
  static const String calenderSettings = '$baseUrl/api/v1/availability';
  //get provider availibility
  static String getProviderAvailability(String providerId) => '$baseUrl/api/v1/availability/$providerId';

  static const String myListingApi = '$baseUrl/api/v1/services/my/services';
  static String getSingleList(String id) => '$baseUrl/api/v1/services/$id';
  static String getMyOrders = '$baseUrl/api/v1/booking/my-bookings';

  //--------------------------------------User site api----------------------------------------------------------

  //** user service */
  static const String userService = '';

  //get all service from provider
  static const String getAllservice = '$baseUrl/api/v1/services';
  //toggle fav api
  static const String toggleFav = "$baseUrl/api/v1/favourite/toggle";
  static const String getFavorites = "$baseUrl/api/v1/favourite/my-favourites";
  //** category api */
  static const String categories = '$baseUrl/api/v1/category';

  //** review api */
  static String getReviewsByProvider(String providerId) => '$baseUrl/api/v1/review/provider/$providerId';

  //** wallet api */
  static const String myWallet = '$baseUrl/api/v1/wallet/my-wallet';
}
