import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sockchat/model/chatMessage.dart';
import 'package:sockchat/model/chatModel.dart';

class ChatMessageProvider extends ChangeNotifier {
  List<ChatMessage> chatMessage = <ChatMessage>[];
  String userID = "";
  String userName = "";
  List<ChatData> chatData = <ChatData>[];

  saveMessagesData(
    dynamic messages,
  ) {
    // chatMessage.add(ChatMessage.fromJson(messages));
    List<ChatData> chatDataNew =
        chatDataFromJson(json.encode(messages).toString());
    chatData = chatDataNew;

    notifyListeners();
  }

  setUserID(
    String setuserID,
  ) {
    userID = setuserID;
    notifyListeners();
  }

  setUserName(
    String newuserName,
  ) {
    userName = newuserName;
    notifyListeners();
  }
}

class SendFileProvider extends ChangeNotifier {
  String filePath = "";
  late File file;
  saveFilePath(String newFilePath) {
    filePath = newFilePath;
    notifyListeners();
  }

  saveFile(File newFile) {
    file = newFile;
    notifyListeners();
  }
}
