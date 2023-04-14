import 'dart:async';

import 'package:chatgpt_app/models/chat_model.dart';
import 'package:chatgpt_app/services/api_services.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];

  List<ChatModel> get getChatList => chatList;

  void addUserMessage({required String message}) {
    chatList.add(ChatModel(message: message, chatIndex: 0));
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswer(
      {required String message, required String modelChosed}) async {
    chatList.addAll(
        await ApiService.sendMessage(message: message, modelId: modelChosed));
    notifyListeners();
  }
}
