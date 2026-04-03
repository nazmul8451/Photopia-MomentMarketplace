// test_socket.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

void main() async {
  print("Starting Socket Test with EXACT Map configuration...");
  
  final String baseUrl = 'http://195.35.6.13:4003';
  
  final socket = IO.io(baseUrl, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
    'forceNew': true,
    'query': {'token': 'MOCK_TOKEN'}, // Testing if query param causes issues
  });

  socket.onConnect((_) {
    print('SUCCESS: Connected successfully!');
    socket.disconnect();
  });

  socket.onConnectError((data) {
    print('FAIL: Connect error: $data');
  });

  socket.onError((data) {
    print('FAIL: General error: $data');
  });

  socket.onDisconnect((_) => print('DISCONNECTED'));

  print("Connecting to $baseUrl...");
  socket.connect();

  print("Waiting 10 seconds for connection...");
  await Future.delayed(Duration(seconds: 10));
  print("Test finished.");
}
