import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/controller/client/user_profile_controller.dart';
import 'package:photopia/controller/client/notification_controller.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/chat_message_model.dart';
import 'package:photopia/data/models/chat_response_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatController extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  ChatData? _chatData;
  List<ChatMessage> _messages = [];

  IO.Socket? _socket;
  String? _currentActiveChatId;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ChatData? get chatData => _chatData;
  List<ChatRoom> get chats => _chatData?.chats ?? [];
  List<ChatMessage> get messages => _messages;

  void reset() {
    _isLoading = false;
    _errorMessage = '';
    _chatData = null;
    _messages = [];
    disconnectSocket();
    notifyListeners();
  }

  Future<void> _recoverUserId() async {
    final String token = AuthController.accessToken ?? '';
    if (token.isEmpty) return;

    print('!!! [SOCKET_DEBUG] RECOVERY: Attempting to fetch profile to recover userId...');
    try {
      // We create a temporary instance to fetch the profile and trigger stay-sync logic 
      // recently added to UserProfileController.
      final profileController = UserProfileController();
      await profileController.getUserProfile();
      print('!!! [SOCKET_DEBUG] RECOVERY: Profile fetch complete. New UserId: ${AuthController.userId}');
    } catch (e) {
      print('!!! [SOCKET_DEBUG] RECOVERY: Failed to recover userId: $e');
    }
  }

  /// Connects to the Socket.IO instance attached at Urls.baseUrl
  Future<void> connectSocket() async {
    if (_socket != null) {
      if (_socket?.disconnected == true) {
        _socket?.connect();
      }
      return;
    }

    String userId = AuthController.userId ?? '';
    if (userId.isEmpty) {
      final cachedProfile = GetStorage().read<Map<String, dynamic>>('cached_user_profile');
      userId = cachedProfile?['id']?.toString() ?? cachedProfile?['_id']?.toString() ?? '';
    }

    // Try active recovery if still empty
    if (userId.isEmpty && AuthController.accessToken != null) {
      await _recoverUserId();
      userId = AuthController.userId ?? '';
    }
    
    final String token = AuthController.accessToken ?? '';

    print('!!! [SOCKET_DEBUG] Attempting connection...');
    print('!!! [SOCKET_DEBUG] URL: ${Urls.baseUrl}');
    print('!!! [SOCKET_DEBUG] UserId: $userId');
    print('!!! [SOCKET_DEBUG] Token exists: ${token.isNotEmpty}');

    if (userId.isEmpty) {
      print('!!! [SOCKET_DEBUG] ABORTING: UserId is empty!');
      return; 
    }

    _socket = IO.io(Urls.baseUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'], // Added polling back as a fallback for Android Emulators
      'autoConnect': false,
      'forceNew': true,
      'query': {'token': token},
    });

    _socket?.onConnect((_) {
      print('!!! [SOCKET_DEBUG] SUCCESS: Realtime Socket Connected Successfully');
    });

    _socket?.onConnectError((data) {
      print('!!! [SOCKET_DEBUG] ERROR (Connect): $data');
    });

    _socket?.onError((data) {
      print('!!! [SOCKET_DEBUG] ERROR (General): $data');
    });

    _socket?.on('updateChatList::$userId', (data) {
      debugPrint('Socket: updateChatList received');
      getChats();
    });

    // Join Notification Room
    print('!!! [SOCKET_DEBUG] Emitting join-notification for $userId');
    _socket?.emit('join-notification', userId);

    _socket?.on('notification', (data) {
      debugPrint('!!! [SOCKET_DEBUG] Notification received: $data');
      NotificationController.instance.onNewNotification(data);
      getChats(); // Ensure chat list updates in real-time when receiving generic pings
    });

    // Catch-all for debug: Log ALL incoming events
    _socket?.onAny((event, data) {
      debugPrint('Socket: Global Listen -> $event, data: $data');
    });

    _socket?.onDisconnect((_) {
      debugPrint('Realtime Socket Disconnected');
    });

    _socket?.connect();
  }

  /// Disconnect and release the Socket
  void disconnectSocket() {
    if (_socket != null) {
      if (_currentActiveChatId != null) {
        _socket?.off('getMessage::$_currentActiveChatId');
      }
      _socket?.off('updateChatList::${AuthController.userId}');
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _currentActiveChatId = null;
    }
  }

  Future<bool> getChats() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    // Ensure socket is alive every time we fetch chats
    connectSocket();

    try {
      final response = await NetworkCaller.getRequest(url: Urls.chat);
      if (response.isSuccess) {
        _chatData = ChatResponse.fromJson(response.body ?? {}).data;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = response.errorMessage ?? 'Failed to load chats';
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
    return false;
  }

  Future<bool> getMessages(String chatId, {String? receiverId}) async {
    _isLoading = true;
    _errorMessage = '';

    connectSocket(); // Ensure socket connection when navigating directly
    
    
    if (chatId.isEmpty) {
      _messages = [];
      _currentActiveChatId = null;
      _isLoading = false;
      notifyListeners();
      return true;
    }
    
    notifyListeners();

    // Socket Room Switching Strategy
    connectSocket(); // Move this up to ensure _socket is created

    if (_socket != null) {
      if (_currentActiveChatId != null && _currentActiveChatId != chatId) {
        debugPrint('Socket: Removing listener for $_currentActiveChatId');
        _socket?.off('getMessage::$_currentActiveChatId');
        _messages = []; // Clear visual ghost messages during transition
      }
      if (_currentActiveChatId != chatId) {
        _currentActiveChatId = chatId;
        debugPrint('Socket: Attaching listener for getMessage::$chatId');
        _socket?.on('getMessage::$chatId', _onNewMessageBase);
      }
    }

    try {
      final response = await NetworkCaller.getRequest(url: Urls.getMessages(chatId));
      if (response.isSuccess) {
        final messageResponse = MessageResponse.fromJson(
          response.body ?? {}, 
          AuthController.userId ?? '', 
          roomReceiverId: receiverId
        );
        _messages = messageResponse.data;
        // Sort newest first for reverse ListView compatibility
        _messages.sort((a, b) => b.time.compareTo(a.time));
        return true;
      }
      _errorMessage = response.errorMessage ?? 'Failed to load messages';
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  void _onNewMessageBase(dynamic data) {
    debugPrint('Socket: getMessage received -> $data');
    if (data != null) {
      try {
        Map<String, dynamic> msgData = {};
        
        if (data is String) {
          try {
            msgData = jsonDecode(data);
          } catch (_) {}
        } else if (data is Map) {
          msgData = Map<String, dynamic>.from(data);
        }

        // Unwrap standard API formatted payloads securely
        if (msgData.containsKey('data') && msgData['data'] is Map) {
          msgData = Map<String, dynamic>.from(msgData['data']);
        }
        
        if (msgData.isEmpty) {
          debugPrint('Socket message discarded: payload was not a valid Map.');
          return;
        }

        final ChatMessage newMsg = ChatMessage.fromJson(msgData, AuthController.userId ?? '');
        
        if (newMsg.id.isEmpty) {
          debugPrint('Socket message discarded: id was mysteriously empty.');
          return;
        }

        // --- De-duplication Strategy ---
        // 1. Check if ID already exists
        final existingIndexById = _messages.indexWhere((m) => m.id == newMsg.id);
        if (existingIndexById != -1) return;

        // 2. If it's from me, check for a matching "sending" message (temp ID)
        if (newMsg.isMe) {
          final tempMsgIndex = _messages.indexWhere((m) => 
            m.isLocal && 
            m.text.trim() == newMsg.text.trim() && 
            m.status == MessageStatus.sending
          );
          
          if (tempMsgIndex != -1) {
            debugPrint('Socket: Matching local message found. Replacing temp ID with server ID.');
            _messages[tempMsgIndex] = newMsg;
            notifyListeners();
            return;
          }
        }

        // 3. Normal insert for new unique messages
        _messages.insert(0, newMsg);
        
        if (_currentActiveChatId != null) {
          _updateChatPreviewLocal(newMsg, _currentActiveChatId!);
        }
        
        notifyListeners();
      } catch (e) {
        debugPrint('Socket format error: $e');
      }
    }
  }

  Future<bool> sendMessage(String chatId, String text, {String? receiverId}) async {
    final String tempId = "temp_${DateTime.now().millisecondsSinceEpoch}";
    final ChatMessage tempMsg = ChatMessage(
      id: tempId,
      senderId: AuthController.userId ?? '',
      text: text,
      time: DateTime.now(),
      type: ChatMessageType.text,
      isMe: true,
      status: MessageStatus.sending,
      isLocal: true,
    );

    // 1. Optimistic Add
    _messages.insert(0, tempMsg);
    _updateChatPreviewLocal(tempMsg, chatId);
    notifyListeners();

    try {
      final Map<String, dynamic> body = {
        'chatId': chatId,
        'text': text,
        'receiver': receiverId,
      };

      final response = await NetworkCaller.postRequest(
        url: Urls.sendMessage,
        body: body,
      );

      if (response.isSuccess) {
        final realMsg = ChatMessage.fromJson(response.body?['data'], AuthController.userId ?? '');
        
        // --- DE-DUPLICATION CHECK ---
        // If the socket message already arrived and added itself via real ID,
        // we just need to remove the temporary message.
        final int indexOfRealMsg = _messages.indexWhere((m) => m.id == realMsg.id);
        final int indexOfTempMsg = _messages.indexWhere((m) => m.id == tempId);

        if (indexOfRealMsg != -1 && indexOfTempMsg != -1) {
          debugPrint('HTTP Success: Real message already present in list (likely via Socket). Removing temp message.');
          _messages.removeAt(indexOfTempMsg);
        } else if (indexOfTempMsg != -1) {
          debugPrint('HTTP Success: Replacing temp message with confirmed server message.');
          _messages[indexOfTempMsg] = realMsg;
        }

        notifyListeners();
        _updateChatPreviewLocal(realMsg, chatId);
        // Refresh preview entirely from server to ensure sync, but without blocking local preview
        getChats();
        return true;
      }
      
      // 3. Error Update
      final int errIndex = _messages.indexWhere((m) => m.id == tempId);
      if (errIndex != -1) {
        _messages[errIndex] = _messages[errIndex].copyWith(status: MessageStatus.error);
      }
      _errorMessage = response.errorMessage ?? 'Failed to send message';
    } catch (e) {
      final int errIndex = _messages.indexWhere((m) => m.id == tempId);
      if (errIndex != -1) {
        _messages[errIndex] = _messages[errIndex].copyWith(status: MessageStatus.error);
      }
      _errorMessage = 'An error occurred: $e';
    }
    notifyListeners();
    return false;
  }

  void _updateChatPreviewLocal(ChatMessage msg, String chatId) {
    if (_chatData?.chats == null) return;
    
    final int chatIndex = _chatData!.chats!.indexWhere((c) => c.sId == chatId);
    if (chatIndex != -1) {
      final chat = _chatData!.chats![chatIndex];
      chat.latestMessage = LatestMessage(
        sId: msg.id,
        content: msg.text,
        sender: msg.senderId,
        createdAt: msg.time.toIso8601String(),
        isSeen: msg.status == MessageStatus.read,
        status: msg.status.name, // sent, delivered, read
      );
      
      // Move this chat to the top of the list
      _chatData!.chats!.removeAt(chatIndex);
      _chatData!.chats!.insert(0, chat);
    }
  }

  Future<bool> sendMediaMessage(String chatId, String filePath, {String? receiverId, String? text}) async {
    _errorMessage = '';
    final String tempId = "temp_${DateTime.now().millisecondsSinceEpoch}";
    final extension = p.extension(filePath).toLowerCase();
    
    ChatMessageType msgType = ChatMessageType.image;
    if (['.mp4', '.mov', '.avi'].contains(extension)) {
      msgType = ChatMessageType.video;
    }

    final ChatMessage tempMsg = ChatMessage(
      id: tempId,
      senderId: AuthController.userId ?? '',
      text: text ?? '',
      fileUrl: filePath, // Use local path for immediate preview
      time: DateTime.now(),
      type: msgType,
      isMe: true,
      status: MessageStatus.sending,
      isLocal: true,
    );

    // 1. Optimistic Add
    _messages.insert(0, tempMsg);
    _updateChatPreviewLocal(tempMsg, chatId);
    notifyListeners();

    String pathToSend = filePath;
    File? tempFile;

    try {
      // Orientation & Compress for Images
      if (['.jpg', '.jpeg', '.png', '.heic'].contains(extension)) {
        final tempDir = await getTemporaryDirectory();
        final targetPath = p.join(tempDir.path, "temp_${DateTime.now().millisecondsSinceEpoch}$extension");
        
        final result = await FlutterImageCompress.compressAndGetFile(
          filePath,
          targetPath,
          quality: 80,
          keepExif: false,
          autoCorrectionAngle: true,
        );

        if (result != null) {
          pathToSend = result.path;
          tempFile = File(pathToSend);
        }
      }

      final Map<String, String> fields = {
        'chatId': chatId,
      };
      if (receiverId != null) {
        fields['receiver'] = receiverId;
      }
      if (text != null && text.isNotEmpty) {
        fields['text'] = text;
      }

      final response = await NetworkCaller.multipartRequest(
        url: Urls.sendMessage,
        method: 'POST',
        fields: fields,
        fileKey: 'images',
        filePath: pathToSend,
      );

      if (response.isSuccess) {
        final realMsg = ChatMessage.fromJson(response.body?['data'], AuthController.userId ?? '');

        // --- DE-DUPLICATION CHECK ---
        final int indexOfRealMsg = _messages.indexWhere((m) => m.id == realMsg.id);
        final int indexOfTempMsg = _messages.indexWhere((m) => m.id == tempId);

        if (indexOfRealMsg != -1 && indexOfTempMsg != -1) {
          debugPrint('HTTP Success (Media): Real message already present in list (likely via Socket). Removing temp message.');
          _messages.removeAt(indexOfTempMsg);
        } else if (indexOfTempMsg != -1) {
          debugPrint('HTTP Success (Media): Replacing temp message with confirmed server message.');
          _messages[indexOfTempMsg] = realMsg;
        }

        notifyListeners();
        _updateChatPreviewLocal(realMsg, chatId);
        // Refresh preview entirely from server to ensure sync, but without blocking local preview
        getChats();
        return true;
      }
      
      // 3. Error Update
      final int errIndex = _messages.indexWhere((m) => m.id == tempId);
      if (errIndex != -1) {
        _messages[errIndex] = _messages[errIndex].copyWith(status: MessageStatus.error);
      }
      _errorMessage = response.errorMessage ?? 'Failed to send media';
    } catch (e) {
      final int errIndex = _messages.indexWhere((m) => m.id == tempId);
      if (errIndex != -1) {
        _messages[errIndex] = _messages[errIndex].copyWith(status: MessageStatus.error);
      }
      _errorMessage = 'An error occurred: $e';
    } finally {
      // Cleanup temp physical file
      if (tempFile != null && await tempFile.exists()) {
        try { await tempFile.delete(); } catch (_) {}
      }
      notifyListeners();
    }
    return false;
  }

  Future<String?> createChatAndSendMessage(String otherUserId, String text) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await NetworkCaller.postRequest(
        url: Urls.createChat(otherUserId),
        body: {},
      );

      if (response.isSuccess) {
        final Map<String, dynamic> data = response.body?['data'] ?? {};
        final String newChatId = (data['_id'] ?? data['id'] ?? '').toString();

        if (newChatId.isNotEmpty) {
          // Immediately send the first message to make it a real chat
          await sendMessage(newChatId, text, receiverId: otherUserId);
          await getChats();
          return newChatId;
        }
      }
      _errorMessage = response.errorMessage ?? 'Failed to initiate chat';
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
    return null;
  }
}
