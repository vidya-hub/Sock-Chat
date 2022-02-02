import 'dart:convert';

import 'package:http/http.dart' as http;

class MessagesService {
  /* 
  local http://192.168.141.41:3000
  heroku https://lit-dawn-80686.herokuapp.com
   */
  static http.Response? response;
  static String clientUrl = "http://192.168.141.41:3000";
  static Future getMessagesFromServer(Map<String, String> userBody) async {
    Uri chatUrl = Uri.parse(
      "$clientUrl/chat/chatdata",
    );
    response = await http.post(
      chatUrl,
      body: json.encode(userBody),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    // print(response);
    // print("===============");
    // print(response!.body);
    // print("===============");
    return json.decode(response!.body);
  }

  // Future _profileUpload(String messageId, String file) async {
  //   var request = http.MultipartRequest(
  //     "POST",
  //     Uri.parse(
  //       "$clientUrl/fileUpload",
  //     ),
  //   );
  //   request.fields["messageId"] = messageId;
  //   var uploadFile = await http.MultipartFile.fromPath("file", file);
  //   request.files.add(uploadFile);
  //   var response = await request.send();
  //   var responseData = await response.stream.toBytes();
  //   var responseString = String.fromCharCodes(responseData);
  //   return responseString;
  // }
}
