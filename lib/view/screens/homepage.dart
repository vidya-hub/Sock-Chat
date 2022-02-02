import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sockchat/controller/chatController.dart';
import 'package:sockchat/main.dart';
import 'package:sockchat/model/chatModel.dart';
import 'package:sockchat/services/messagesSevice.dart';
import 'package:sockchat/view/components/chatBubble.dart';
import 'package:sockchat/view/screens/roomScreen.dart';
import 'package:socket_io_client/socket_io_client.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  late String username;
  HomePage({required this.username});
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
    String clientUrl = MessagesService.clientUrl;
    socket = io(clientUrl, <String, dynamic>{
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
      socket.emit(
        "signIn",
        {widget.username: socket.id},
      );
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
      // messages.saveMessagesData(data);
      // print(messages.chatMessage.length);
    });
  }

  Future<List<ChatData>> getMessagesDataFromApi() async {
    try {
      var messagesData = await MessagesService.getMessagesFromServer(
          {"userName": widget.username});
      print("Innnnn");
      print(messagesData);
      if (messagesData != null || messagesData != {}) {
        List<ChatData> chatData =
            chatDataFromJson(json.encode(messagesData).toString());

        print("Innnnn");
        print(chatData.length);
        print("Innnnn");
        return chatData;
      } else {
        return <ChatData>[];
      }
    } catch (e) {
      return <ChatData>[];
    }
  }

  Stream<List<ChatData>> getMessagesStrema() async* {
    while (true) {
      var messagesData = await MessagesService.getMessagesFromServer(
          {"userName": widget.username});
      // print("Innnnn");
      print(messagesData);
      if (messagesData != null || messagesData != {}) {
        List<ChatData> chatData =
            chatDataFromJson(json.encode(messagesData).toString());

        yield chatData;
      } else {
        yield <ChatData>[];
      }
    }
  }

  final TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  @override
  void dispose() {
    super.dispose();
  }

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
    return Scaffold(
      appBar: appbarWidget(),
      body: WillPopScope(
        onWillPop: () {
          socket.emit("forceDisconnect");
          return Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) {
                return RoomScreen();
              },
            ),
            (route) => false,
          ) as Future<bool>;
        },
        child: SafeArea(
          child: Container(
            height: height,
            width: width,
            // color: Colors.amberAccent,
            child: Column(
              children: [
                Expanded(
                  flex: 9,
                  child: Consumer<ChatMessageProvider>(
                    builder: (context, messagesProviderValue, child) {
                      print(messagesProviderValue.chatData.length);
                      return Container(
                        // color: Colors.amber,
                        height: height * 0.78,
                        child: ListView.builder(
                          itemCount: messagesProviderValue.chatData.length,
                          controller: _scrollController,
                          itemBuilder: (BuildContext context, int index) {
                            if (messagesProviderValue.chatData.length <= 0) {
                              return Center(
                                child: Text("No Chat Messages"),
                              );
                            } else {
                              return chatBubble(
                                height,
                                width,
                                message: messagesProviderValue
                                    .chatData[index].message,
                                fileArray: Uint8List.fromList(
                                    messagesProviderValue
                                        .chatData[index].fileDetails.fileArray),
                                fileName: messagesProviderValue
                                    .chatData[index].fileDetails.fileName,
                                isSender: messagesProviderValue
                                        .chatData[index].userName ==
                                    widget.username,
                                userName: messagesProviderValue
                                    .chatData[index].userName,
                                time: DateFormat('jms').format(
                                  messagesProviderValue
                                      .chatData[index].dateTime,
                                ),
                                messageType: messagesProviderValue
                                    .chatData[index].messageType,
                                // messagesProviderValue.chatMessage[index].userID,
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                Consumer<SendFileProvider>(
                  builder: (context, value, child) {
                    // print(value.filePath);
                    return Container(
                      // color: Colors.amberAccent,
                      height:
                          value.filePath == "" ? height * 0.1 : height * 0.25,
                      width: width * 0.9,
                      padding: EdgeInsets.only(bottom: height * 0.01),
                      alignment: Alignment.center,
                      child: ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          value.filePath != ""
                              ? fileWindow(height, value)
                              : Container(),
                          Container(
                            // color: Colors.black,
                            height: height * 0.08,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                messageField(
                                  height,
                                  width,
                                  context,
                                  fileProvider,
                                ),
                                chatButtonsRow(
                                  height,
                                  width,
                                  context,
                                  fileProvider,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget chatButtonsRow(double height, double width, BuildContext context,
      SendFileProvider fileProvider) {
    return Container(
      alignment: Alignment.bottomCenter,
      // color: Colors.amber,
      height: height * 0.1,
      width: width * 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          chatButtons(
            height,
            Icons.file_upload_outlined,
            () async {
              await fileShare();
            },
          ),
          chatButtons(
            height,
            Icons.send_outlined,
            () async {
              await sendMessage(
                context,
                fileProvider,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget chatButtons(
    double height,
    IconData icon,
    GestureTapCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height * 0.05,
        width: height * 0.05,
        decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Icon(
          icon,
          color: Colors.white,
          size: 15,
        ),
      ),
    );
  }

  Widget messageField(
    double height,
    double width,
    BuildContext context,
    SendFileProvider fileProvider,
  ) {
    return Container(
      height: height * 0.1,
      width: width * 0.6,
      alignment: Alignment.bottomCenter,
      child: TextField(
        controller: _messageController,
        onSubmitted: (textvalue) async {
          await sendMessage(
            context,
            fileProvider,
          );
        },
        decoration: InputDecoration(
          hintText: "Enter your message",
          // border: Border.all(),
        ),
      ),
    );
  }

  Container fileWindow(
    double height,
    SendFileProvider value,
  ) {
    return Container(
      height: height * 0.1,
      color: Colors.blueGrey,
      child: Card(
        child: Stack(
          children: [
            Center(
              child: Text(
                value.filePath.split("/").last,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    value.saveFilePath("");
                  },
                  child: CircleAvatar(
                    radius: height * 0.014,
                    child: Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: height * 0.02,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  AppBar appbarWidget() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.green,
      title: Consumer<ChatMessageProvider>(
        builder: (context, userIDProvider, child) {
          return Text(
            "${widget.username}",
          );
        },
      ),
    );
  }

  Future fileShare() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File getFileInMb = File(result.files.single.path.toString());
      double getSize = await getFileSize(getFileInMb);
      if (getSize > 0.5) {
        showToast("File size should be less than 500 kb");
        return;
      }
      final fileProvider = Provider.of<SendFileProvider>(
        context,
        listen: false,
      );
      fileProvider.saveFilePath(getFileInMb.path);
      fileProvider.saveFile(getFileInMb);
    } else {
      showToast("Please Select file to share");
      // User canceled the picker
    }
  }

  Future getFileSize(File file) async {
    Uint8List fileArray = await file.readAsBytes();

    final kb = fileArray.lengthInBytes / 1024;
    final mb = kb / 1024;
    print(mb);
    return mb;
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
    SendFileProvider fileProvider,
  ) async {
    String fileName = (fileProvider.filePath);
    if (_messageController.text == "") {
      if (fileProvider.filePath == "") {
        showToast("Please enter Message");
        return;
      }
    }
    if (fileName != "") {
      Uint8List fileArray = await File(fileName).readAsBytes();

      Map<String, dynamic> sendData = {
        "message": _messageController.text.trim(),
        "userName": widget.username,
        "id": socket.id,
        "dateTime": DateTime.now().toString(),
        "messageType": "File",
        "fileDetails": {
          "fileName": fileName,
          "fileArray": fileArray,
        }
      };
      socket.emit("sendMessage", sendData);

      // final messages = Provider.of<
      //     ChatMessageProvider>(
      //   context,
      //   listen: false,
      // );
      // messages.saveMessagesData(sendData);
      // print(messages.chatMessage);
      _messageController.clear();
      scrollToBottom(_scrollController);
      fileProvider.saveFilePath("");
    } else {
      Map<String, dynamic> sendData = {
        "message": _messageController.text.trim(),
        "userName": widget.username,
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
      // final messages = Provider.of<
      //     ChatMessageProvider>(
      //   context,
      //   listen: false,
      // );
      // messages.saveMessagesData(sendData);
      // print(messages.chatMessage);
      _messageController.clear();
      scrollToBottom(_scrollController);
    }
  }
}



/* 


                  //  StreamBuilder<List<ChatData>>(
                  //     stream: getMessagesStrema(),
                  //     builder: (context, snapshot) {
                  //       print(snapshot.data);
                  //       return !snapshot.hasData
                  //           ? Center(
                  //               child: CircularProgressIndicator(),
                  //             )
                  //           : Container(
                  //               // color: Colors.amber,
                  //               height: height * 0.78,
                  //               child: snapshot.data!.length <= 0
                  //                   ? Center(
                  //                       child: Text(
                  //                         "No Chat Messages",
                  //                         style: TextStyle(
                  //                           color: Colors.black,
                  //                           fontWeight: FontWeight.bold,
                  //                         ),
                  //                       ),
                  //                     )
                  //                   :

                  //                   ListView.builder(
                  //                       itemCount: snapshot.data!.length,
                  //                       controller: _scrollController,
                  //                       itemBuilder:
                  //                           (BuildContext context, int index) {
                  //                         // print(chatDataProvider.chatData);
                  //                         ChatData chatData =
                  //                             snapshot.data![index];
                  //                         return chatBubble(
                  //                           height,
                  //                           width,
                  //                           message: chatData.message,
                  //                           fileArray: Uint8List.fromList(
                  //                               chatData.fileDetails.fileArray),
                  //                           fileName:
                  //                               chatData.fileDetails.fileName,
                  //                           isSender: chatData.userName ==
                  //                               widget.username,
                  //                           userName: chatData.userName,
                  //                           time: DateFormat('jms').format(
                  //                             chatData.dateTime,
                  //                           ),
                  //                           messageType: chatData.messageType,
                  //                           // messagesProviderValue.chatMessage[index].userID,
                  //                         );
                  //                       }),
                  //             );
                  //     }),


 */