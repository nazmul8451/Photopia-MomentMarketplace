import 'package:http/http.dart' ;

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


class NetworkCaller{

  static Future<NetworkResponse> getRequest({required String url, String? token}) async {

    try{
      final Uri uri = Uri.parse(url);
      final  Map<String,String> headers = {'Accept' :"application/json"};

      final Response response = await get(uri,headers: headers);




    }catch(e){

    }

  }
}
