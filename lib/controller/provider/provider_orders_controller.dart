import 'package:get/get.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';

class ProviderOrdersController extends GetxController {
  bool inProgress = false;
  String errorMessage = '';
  List<dynamic> orders = [];

  Future<bool> getMyOrders() async {
    inProgress = true;
    update();

    final response = await NetworkCaller.getRequest(url: Urls.getMyOrders);

    inProgress = false;

    if (response.isSuccess) {
      if (response.body != null && response.body!['data'] != null) {
        orders = response.body!['data']; // Will update with proper model later
      }
      update();
      return true;
    } else {
      errorMessage = response.errorMessage ?? 'Failed to fetch orders';
      update();
      return false;
    }
  }
}
