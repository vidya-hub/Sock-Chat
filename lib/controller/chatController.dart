import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sockchat/model/chatMessage.dart';

class ChatMessageProvider extends ChangeNotifier {
  List<ChatMessage> chatMessage = <ChatMessage>[];
  String userID = "";
  saveMessagesData(
    Map<String, dynamic> messages,
  ) {
    chatMessage.add(ChatMessage.fromJson(messages));
    notifyListeners();
  }

  setUserID(
    String setuserID,
  ) {
    userID = setuserID;
    notifyListeners();
  }
}

class SendFileProvider extends ChangeNotifier {
  String filePath = "";
  saveFilePath(String newFilePath) {
    filePath = newFilePath;
    notifyListeners();
  }
}
