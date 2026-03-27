import 'dart:io';

void main() {
  final file = File('lib/features/client/widgets/horizontal_project_card.dart');
  String content = file.readAsStringSync();
  
  // 1. Add missing imports
  if (!content.contains('network_caller.dart')) {
    content = "import 'package:photopia/core/network/Api_service/network_caller.dart';\n"
              "import 'package:photopia/core/network/urls.dart';\n"
              + content;
  }

  // 2. Add FutureBuilder block if not patched yet
  if (!content.contains('FutureBuilder<NetworkResponse>')) {
    final regex = RegExp(
      r'(\s+)child:\s+CustomNetworkImage\(\s+imageUrl:\s+imageUrl,\s+width:\s+140\.w,\s+height:\s+125\.h,\s+fit:\s+BoxFit\.cover,\s+\),',
      multiLine: true,
    );
    
    if (regex.hasMatch(content)) {
      content = content.replaceFirstMapped(regex, (match) {
        final indent = match.group(1)!;
        final spaces = ' ' * (indent.length - 1);
        final widget = '''
${indent}child: (imageUrl != null && imageUrl.isNotEmpty)
${spaces}  ? CustomNetworkImage(
${spaces}      imageUrl: imageUrl,
${spaces}      width: 140.w,
${spaces}      height: 125.h,
${spaces}      fit: BoxFit.cover,
${spaces}    )
${spaces}  : FutureBuilder<NetworkResponse>(
${spaces}      future: NetworkCaller.getRequest(url: Urls.getSingleList(id), requireAuth: false),
${spaces}      builder: (context, snapshot) {
${spaces}        if (snapshot.connectionState == ConnectionState.waiting) {
${spaces}          return Container(width: 140.w, height: 125.h, color: Color(0xFFEEEEEE), alignment: Alignment.center, child: Text('...'));
${spaces}        }
${spaces}        String? fetchedUrl;
${spaces}        if (snapshot.hasData && snapshot.data!.isSuccess && snapshot.data!.body != null) {
${spaces}          final data = snapshot.data!.body!['data'];
${spaces}          if (data != null) {
${spaces}            fetchedUrl = data['coverMedia'] ?? (data['gallery'] != null && (data['gallery'] as List).isNotEmpty ? (data['gallery'] as List).first : null);
${spaces}          }
${spaces}        }
${spaces}        if (fetchedUrl != null && fetchedUrl.isNotEmpty) {
${spaces}          return CustomNetworkImage(imageUrl: fetchedUrl, width: 140.w, height: 125.h, fit: BoxFit.cover);
${spaces}        } else {
${spaces}          return CustomNetworkImage(imageUrl: '', width: 140.w, height: 125.h, fit: BoxFit.cover); // Default grey placeholder without const
${spaces}        }
${spaces}      },
${spaces}    ),''';
        return widget;
      });

      print('Successfully generated Replacement String!');
    } else {
      print('Failed to match CustomNetworkImage block.');
    }
  } else {
    print('Already patched with FutureBuilder.');
  }

  file.writeAsStringSync(content);
}
