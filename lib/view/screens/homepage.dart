import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sockchat/controller/chatController.dart';
import 'package:sockchat/main.dart';
import 'package:sockchat/model/chatMessage.dart';
import 'package:sockchat/view/components/chatBubble.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Socket socket;
  String userID = "";
  @override
  void initState() {
    super.initState();
    socketConnect();
    socketListen(context);
  }

  Future socketConnect() async {
    socket = io("http://192.168.141.41:3000/", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": true,
    });
    socket.connect();
    socket.on('connect', (data) {
      print(socket.connected);
      Provider.of<ChatMessageProvider>(
        context,
        listen: false,
      ).setUserID(socket.id.toString());
    });
  }

  socketListen(BuildContext context) {
    final messages = Provider.of<ChatMessageProvider>(
      context,
      listen: false,
    );
    socket.on("receivedMessage", (data) {
      print(data);
      messages.saveMessagesData(data);
      print(messages.chatMessage.length);
    });
  }

  final TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  @override
  Widget build(
    BuildContext context,
  ) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final fileProvider = Provider.of<SendFileProvider>(
      context,
      listen: false,
    );
    final messages = Provider.of<ChatMessageProvider>(
      context,
      listen: false,
    ).chatMessage;
    // List<ChatMessage> chatmesssage = watch(chatMessageProvider).state;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green,
        title: Consumer<ChatMessageProvider>(
          builder: (context, userIDProvider, child) {
            return Text(
              "Sock-Chat ${userIDProvider.userID}",
            );
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          height: height,
          width: width,
          // color: Colors.amberAccent,
          child: Column(
            children: [
              Consumer<ChatMessageProvider>(
                builder: (context, messagesProviderValue, child) {
                  return Expanded(
                    flex: 9,
                    child: Container(
                      // color: Colors.amber,
                      height: height * 0.78,
                      child: ListView.builder(
                        itemCount: messagesProviderValue.chatMessage.length,
                        controller: _scrollController,
                        itemBuilder: (BuildContext context, int index) {
                          if (messagesProviderValue.chatMessage.length <= 0) {
                            return Center(
                              child: Text("No Chat Messages"),
                            );
                          } else {
                            return chatBubble(
                              height,
                              width,
                              message: messagesProviderValue
                                  .chatMessage[index].message,
                              fileArray: messagesProviderValue
                                  .chatMessage[index].sendFile.fileArray,
                              fileName: messagesProviderValue
                                  .chatMessage[index].sendFile.fileName,
                              isSender: messagesProviderValue
                                      .chatMessage[index].userID ==
                                  socket.id,
                              userName: messagesProviderValue
                                  .chatMessage[index].userID,
                              time: DateFormat('jms').format(
                                messagesProviderValue
                                    .chatMessage[index].dateTime,
                              ),
                              messageType: messagesProviderValue
                                  .chatMessage[index].messageType,
                              // messagesProviderValue.chatMessage[index].userID,
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
              Consumer<SendFileProvider>(
                builder: (context, value, child) {
                  print(value.filePath);
                  return Expanded(
                    flex: value.filePath != "" ? 3 : 1,
                    child: Container(
                      color: Colors.amberAccent,
                      height: height * 0.2,
                      width: width * 0.9,
                      padding: EdgeInsets.only(bottom: height * 0.01),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: height * 0.2,
                            width: width * 0.6,
                            alignment: Alignment.bottomCenter,
                            child: TextField(
                              controller: _messageController,
                              onSubmitted: (value) {
                                if (_messageController.text == null ||
                                    _messageController.text == "") {
                                  showToast("Please enter Message");
                                  return;
                                }
                                sendMessage(context);

                                _messageController.clear();
                                scrollToBottom(_scrollController);
                              },
                              decoration: InputDecoration(
                                hintText: "Enter your message",
                                // border: Border.all(),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            // color: Colors.amber,
                            height: height * 0.2,
                            width: width * 0.2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await fileShare();
                                  },
                                  child: Container(
                                    height: height * 0.05,
                                    width: height * 0.05,
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Icon(
                                      Icons.file_upload_outlined,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    String fileName = (fileProvider.filePath);
                                    if (_messageController.text == null ||
                                        _messageController.text == "") {
                                      showToast("Please enter Message");
                                      return;
                                    }
                                    if (fileName != "") {
                                      /* 
                                  
                                    File Sharing
                                  
                                   */
                                      Uint8List fileArray =
                                          await File(fileName).readAsBytes();
                                      Map<String, dynamic> sendData = {
                                        "message":
                                            _messageController.text.trim(),
                                        "id": socket.id,
                                        "dateTime": DateTime.now().toString(),
                                        "messageType": "File",
                                        "fileDetails": {
                                          "fileName": fileName,
                                          "fileArray": fileArray,
                                        }
                                      };
                                      socket.emit("sendMessage", sendData);
                                      final messages =
                                          Provider.of<ChatMessageProvider>(
                                        context,
                                        listen: false,
                                      );
                                      messages.saveMessagesData(sendData);
                                      print(messages.chatMessage);
                                      _messageController.clear();
                                      scrollToBottom(_scrollController);
                                      fileProvider.saveFilePath("");
                                    } else {
                                      /* 
                                  
                                    Text Sharing
                                  
                                   */
                                      Map<String, dynamic> sendData = {
                                        "message":
                                            _messageController.text.trim(),
                                        "id": socket.id,
                                        "dateTime": DateTime.now().toString(),
                                        "messageType": "Text",
                                        "fileDetails": {
                                          "fileName": "",
                                          "fileArray": Uint8List.fromList(
                                            [10, 10],
                                          ),
                                        }
                                      };
                                      socket.emit("sendMessage", sendData);
                                      final messages =
                                          Provider.of<ChatMessageProvider>(
                                        context,
                                        listen: false,
                                      );
                                      messages.saveMessagesData(sendData);
                                      print(messages.chatMessage);
                                      _messageController.clear();
                                      scrollToBottom(_scrollController);
                                    }
                                  },
                                  child: Container(
                                    height: height * 0.05,
                                    width: height * 0.05,
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Icon(
                                      Icons.send_outlined,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future fileShare() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path.toString());
      final fileProvider = Provider.of<SendFileProvider>(
        context,
        listen: false,
      );
      fileProvider.saveFilePath(file.path);
    } else {
      showToast("Please Select file to share");
      // User canceled the picker
    }
  }

  Future scrollToBottom(ScrollController scrollController) async {
    while (scrollController.position.pixels !=
        scrollController.position.maxScrollExtent) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
      await SchedulerBinding.instance!.endOfFrame;
    }
  }

  Future sendMessage(
    BuildContext context,
  ) async {
    Map<String, dynamic> sendData = {
      "message": _messageController.text.trim(),
      "id": socket.id,
      "dateTime": DateTime.now().toString(),
    };
    socket.emit("sendMessage", sendData);

    final messages = Provider.of<ChatMessageProvider>(
      context,
      listen: false,
    );
    messages.saveMessagesData(sendData);
    print(messages.chatMessage);
    // socketListen();
  }
}
