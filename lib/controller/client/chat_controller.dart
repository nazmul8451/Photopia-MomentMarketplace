import 'package:flutter/material.dart';
import 'package:photopia/controller/auth_controller.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/chat_message_model.dart';
import 'package:photopia/data/models/chat_response_model.dart';

class ChatController extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  ChatData? _chatData;
  List<ChatMessage> _messages = [];

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ChatData? get chatData => _chatData;
  List<ChatRoom> get chats => _chatData?.chats ?? [];
  List<ChatMessage> get messages => _messages;

  Future<bool> getChats() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

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
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> getMessages(String chatId, {String? receiverId}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(url: Urls.getMessages(chatId));
      if (response.isSuccess) {
        final messageResponse = MessageResponse.fromJson(
          response.body ?? {}, 
          AuthController.userId ?? '', 
          roomReceiverId: receiverId
        );
        _messages = messageResponse.data;
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

  Future<bool> sendMessage(String chatId, String text, {String? receiverId}) async {
    try {
      // Support multiple key names just in case the backend expects 'content' or 'text'
      final Map<String, dynamic> body = {
        'chatId': chatId,
        'text': text,      // Matches Postman exactly
        'message': text,   // Legacy fallback
        'content': text,   // Legacy fallback
        'receiver': receiverId,
      };

      final response = await NetworkCaller.postRequest(
        url: Urls.sendMessage,
        body: body,
      );

      if (response.isSuccess) {
        await getMessages(chatId, receiverId: receiverId);
        return true;
      }
      _errorMessage = response.errorMessage ?? 'Failed to send message';
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    }
    notifyListeners();
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
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }
}
