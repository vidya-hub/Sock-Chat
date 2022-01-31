import 'dart:typed_data';

class ChatMessage {
  late String userID;
  late String message;
  late DateTime dateTime;
  late SendFile sendFile;
  late String messageType;
  ChatMessage({
    required this.message,
    required this.userID,
    required this.dateTime,
    required this.sendFile,
    required this.messageType,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> msg) {
    return ChatMessage(
        message: msg["message"],
        userID: msg["id"],
        dateTime: DateTime.parse(msg["dateTime"]),
        messageType: msg["messageType"],
        sendFile: SendFile.fromJson(
          msg["fileDetails"],
        )
        // messageType: msg["messageType"],
        );
  }
}

class SendFile {
  late String fileName;
  Uint8List fileArray;
  SendFile({
    required this.fileName,
    required this.fileArray,
  });
  factory SendFile.fromJson(Map<String, dynamic> msg) {
    return SendFile(
      fileName: msg["fileName"],
      fileArray: msg["fileArray"],
    );
  }
  Map<String, dynamic> toJson() => {
        "fileName": fileName,
        "fileArray": fileArray,
      };
}
