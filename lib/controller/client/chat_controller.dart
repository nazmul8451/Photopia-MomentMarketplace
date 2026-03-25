import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/chat_response_model.dart';

class ChatController extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  ChatData? _chatData;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ChatData? get chatData => _chatData;
  List<ChatRoom> get chats => _chatData?.chats ?? [];

  Future<bool> getChats() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(url: Urls.chat);
      
      if (response.isSuccess) {
        final chatResponse = ChatResponse.fromJson(response.body ?? {});
        _chatData = chatResponse.data;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? 'Failed to load chats';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
