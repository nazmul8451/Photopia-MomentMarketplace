import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    final res = await http.get(Uri.parse('http://10.10.7.50:4003/api/v1/services'));
    final Map<String, dynamic> body = jsonDecode(res.body);
    final List data = body['data']['data'] as List;
    final davinci = data.firstWhere((e) => e['title'] != null && e['title'].toString().contains('DaVinci'), orElse: () => null);
    
    if (davinci != null) {
      print("===== RAW JSON FROM /api/v1/services (List API) =====");
      print(const JsonEncoder.withIndent('  ').convert(davinci));
      print("=====================================================");
      print("Notice: 'gallery' and 'coverMedia' do NOT exist in this output!");
    } else {
      print("DaVinci Resolve not found in the list.");
    }
  } catch (e) {
    print("Error: $e");
  }
}
