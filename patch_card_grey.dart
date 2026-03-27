import 'dart:io';

void main() {
  final file = File('lib/features/client/widgets/horizontal_project_card.dart');
  String content = file.readAsStringSync();
  
  if (content.contains('FutureBuilder<NetworkResponse>')) {
    print('Already patched.');
    return;
  }

  // Very precise regex to match the CustomNetworkImage block
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
${spaces}          return const CustomNetworkImage(imageUrl: '', width: 140.w, height: 125.h, fit: BoxFit.cover); // Default grey placeholder
${spaces}        }
${spaces}      },
${spaces}    ),''';
      return widget;
    });

    file.writeAsStringSync(content);
    print('Successfully patched HorizontalProjectCard!');
  } else {
    print('Failed to match CustomNetworkImage block.');
  }
}
