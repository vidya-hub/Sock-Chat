import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sockchat/model/chatModel.dart';
import 'package:sockchat/services/messagesSevice.dart';

class MessagesProvider extends ChangeNotifier {
  late String userName;
  late bool isLoading = false;
  List<ChatData> chatData = <ChatData>[];

  Future getChats(String userName) async {
    isLoading = true;
    notifyListeners();
    dynamic response =
        await MessagesService.getMessagesFromServer({"userName": userName});
    print(response);
    if (response != null || response != []) {
      List<ChatData> chatDataNew =
          chatDataFromJson(json.encode(response).toString());
      chatData.addAll(chatDataNew);
      isLoading = false;
      notifyListeners();
    } else {
      chatData = <ChatData>[];
      isLoading = false;
      notifyListeners();
    }
  }
}
