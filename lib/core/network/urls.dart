class Urls {
  //live url -https://mohosin5003.binarybards.online
  static const String baseUrl = 'https://mohosin5003.binarybards.online';
  //local url - http://10.10.7.50:4003
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
  static const String updateUserProfile = '$baseUrl/api/v1/users/profile'; // PATCH FOR UPDATE PROFILE
  static const String subscriptionPlans = '$baseUrl/api/v1/subscription/plans';
  static const String createSubscription = '$baseUrl/api/v1/subscription/create';

  //Role api
  static const String role = '$baseUrl/api/v1/users/switch-role';

  //provider

  //** serivce api */
  static const String service = '$baseUrl/api/v1/services';
  static const String professionalProfile = '$baseUrl/api/v1/professional-profiles';
  static const String removeProfProfileItems = '$baseUrl/api/v1/professional-profiles/remove-items';
  static String updateService(String id) => '$baseUrl/api/v1/services/$id';
  static String deleteService(String id) => '$baseUrl/api/v1/services/$id';
  static String toggleServiceStatus(String id) => '$baseUrl/api/v1/services/$id/status';
  static String getServicesByProvider(String providerId) => '$baseUrl/api/v1/services/provider/$providerId';
  //Calender and availibility
  static const String calenderSettings = '$baseUrl/api/v1/availability';
  //get provider availibility
  static String getProviderAvailability(String providerId) => '$baseUrl/api/v1/availability/$providerId';
  static String getMonthCalendar(String providerId, int month, int year) => '$baseUrl/api/v1/availability/calendar/$providerId?month=$month&year=$year';
  static String getTimeSlots(String providerId, String date, int duration) => '$baseUrl/api/v1/availability/slots/$providerId?date=$date&duration=$duration';

  static const String myListingApi = '$baseUrl/api/v1/services/my/services';
  static String getSingleList(String id) => '$baseUrl/api/v1/services/$id';
  static String getMyOrders({String? filterType, String? status}) {
    String url = '$baseUrl/api/v1/booking/my-bookings';
    List<String> queries = [];
    if (filterType != null) queries.add('filterType=$filterType');
    if (status != null) queries.add('status=$status');
    if (queries.isNotEmpty) {
      url += '?${queries.join('&')}';
    }
    return url;
  }
  static String getSingleBooking(String id) => '$baseUrl/api/v1/booking/$id';

  //--------------------------------------User site api----------------------------------------------------------

  //** user service */
  static const String userService = '';

  static const String getMyNotification = '$baseUrl/api/v1/notifications/my';
  static const String getNotificationStats = '$baseUrl/api/v1/notifications/stats';
  static const String markAllNotificationsAsRead = '$baseUrl/api/v1/notifications/read-all';
  static String markSingleNotificationAsRead(String id) => '$baseUrl/api/v1/notifications/$id/read';

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

  //** chat api */
  static const String chat = '$baseUrl/api/v1/chat';
  static String getMessages(String chatId) => '$baseUrl/api/v1/message/$chatId';
  static const String sendMessage = '$baseUrl/api/v1/message';
  static String createChat(String otherUserId) => '$baseUrl/api/v1/chat/$otherUserId';

  static const String statistics = '$baseUrl/api/v1/professional-profiles/statistics';
  static const String statisticsExport = '$baseUrl/api/v1/professional-profiles/statistics/export';
  
  //** payment api */
  static const String createCheckoutSession = '$baseUrl/api/v1/payment/create-checkout-session';
  static const String createPaymentIntent = '$baseUrl/api/v1/payment/create-payment-intent';
  static const String myPayments = '$baseUrl/api/v1/payment/my-payments';

  static const String createBooking = '$baseUrl/api/v1/booking';

  static String updateBookingStatus(String id) => '$baseUrl/api/v1/booking/$id/status';

  //public api
  static const String termsAndConditions = '$baseUrl/api/v1/public/terms-and-condition';
}
