// To parse this JSON data, do
//
//     final chatData = chatDataFromJson(jsonString);

import 'dart:convert';

List<ChatData> chatDataFromJson(String str) =>
    List<ChatData>.from(json.decode(str).map((x) => ChatData.fromJson(x)));

String chatDataToJson(List<ChatData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatData {
  ChatData({
    required this.fileDetails,
    required this.id,
    required this.message,
    required this.userName,
    required this.dateTime,
    required this.messageType,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.expireAt,
  });

  FileDetails fileDetails;
  String id;
  String message;
  String userName;
  DateTime dateTime;
  String messageType;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  DateTime expireAt;

  factory ChatData.fromJson(Map<String, dynamic> json) => ChatData(
        fileDetails: FileDetails.fromJson(json["fileDetails"]),
        id: json["_id"],
        message: json["message"],
        userName: json["userName"],
        dateTime: DateTime.parse(json["dateTime"]),
        messageType: json["messageType"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        expireAt: DateTime.parse(json["expire_at"]),
      );

  Map<String, dynamic> toJson() => {
        "fileDetails": fileDetails.toJson(),
        "_id": id,
        "message": message,
        "userName": userName,
        "dateTime": dateTime.toIso8601String(),
        "messageType": messageType,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "expire_at": expireAt.toIso8601String(),
      };
}

class FileDetails {
  FileDetails({
    required this.fileName,
    required this.fileArray,
  });

  String fileName;
  List<int> fileArray;

  factory FileDetails.fromJson(Map<String, dynamic> json) => FileDetails(
        fileName: json["fileName"],
        fileArray: List<int>.from(json["fileArray"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "fileName": fileName,
        "fileArray": List<dynamic>.from(fileArray.map((x) => x)),
      };
}
