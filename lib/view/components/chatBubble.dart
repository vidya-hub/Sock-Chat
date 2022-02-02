import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Padding chatBubble(
  double height,
  double width, {
  required bool isSender,
  required String message,
  required String userName,
  required String time,
  required String fileName,
  required Uint8List fileArray,
  required String messageType,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      onTap: () async {
        if (messageType != "Text") {
          await openFile(fileName, fileArray);
        }
      },
      child: Container(
        height: messageType == "Text" ? height * 0.15 : height * 0.3,
        width: width * 0.3,
        // color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                // color: Colors.amber,
                height: height * 0.028,
                width: width * 0.32,
                alignment:
                    !isSender ? Alignment.centerLeft : Alignment.centerRight,
                child: Text(
                  userName,
                ),
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Expanded(
                flex: 2,
                child: messageType == "Text"
                    ? textBubble(isSender, height, width, message, time)
                    : fileTypeChatBubble(
                        isSender, height, width, message, fileName, time),
              ),
            ],
          ),
        ),
        // child: Conta,
      ),
    ),
  );
}

Container textBubble(
    bool isSender, double height, double width, String message, String time) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.only(
        bottomLeft: isSender
            ? Radius.circular(
                10,
              )
            : Radius.elliptical(0, 10),
        bottomRight: !isSender
            ? Radius.circular(
                10,
              )
            : Radius.elliptical(0, 10),
        topLeft: Radius.circular(
          10,
        ),
        topRight: Radius.circular(
          10,
        ),
      ),
    ),
    height: height * 0.05,
    width: width * 0.6,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            width: width * 0.55,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
              ),
            ),
          ),
        ),
        SizedBox(
          height: height * 0.01,
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              alignment: Alignment.centerRight,
              // color: Colors.amber,
              padding: EdgeInsets.only(
                right: width * 0.02,
              ),
              height: height * 0.1,
              width: width * 0.3,
              child: Text(time),
            ),
          ),
        ),
      ],
    ),
  );
}

Container fileTypeChatBubble(bool isSender, double height, double width,
    String message, String fileName, String time) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.only(
        bottomLeft: isSender
            ? Radius.circular(
                10,
              )
            : Radius.elliptical(0, 10),
        bottomRight: !isSender
            ? Radius.circular(
                10,
              )
            : Radius.elliptical(0, 10),
        topLeft: Radius.circular(
          10,
        ),
        topRight: Radius.circular(
          10,
        ),
      ),
    ),
    height: height * 0.05,
    width: width * 0.6,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            // color: Colors.blueGrey,
            width: width * 0.55,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      // color: Colors.amber,
                      child: Text(
                        message,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Expanded(
                      flex: 3,
                      child: Container(
                        // width: width,
                        child: Card(
                          color: Colors.white,
                          shadowColor: Colors.green,
                          elevation: 5,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.02,
                              ),
                              child: Text(
                                fileName.split("/").last,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              alignment: Alignment.centerRight,
              // color: Colors.amber,
              padding: EdgeInsets.only(
                right: width * 0.02,
              ),
              height: height * 0.1,
              width: width * 0.3,
              child: Text(time),
            ),
          ),
        ),
        SizedBox(
          height: height * 0.01,
        ),
      ],
    ),
  );
}

Future openFile(
  String fileName,
  var fileArray,
) async {
  File(fileName).exists().then((value) async {
    if (value) {
      OpenFile.open(fileName);
    } else {
      print("Not Exists");
      var dir = await getExternalStorageDirectory();
      String filenameNew = fileName.split("/").last;
      var tempPath = File("${dir!.path}/$filenameNew");
      await tempPath.writeAsBytes(fileArray, flush: true).then((value) {
        OpenFile.open(tempPath.path);
      });
    }
  });
}

String getDateTime(
  String dateTime,
) {
  DateFormat dateFormat = DateFormat(
    "yyyy-MM-dd HH:mm",
  );
  dateFormat.format(DateTime.now());

  return "Stringg";
}
