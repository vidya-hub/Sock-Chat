import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:sockchat/view/screens/homepage.dart';

import '../../main.dart';

class RoomScreenComponents {
  static Container logoWidget(double height) {
    return Container(
      height: height * 0.2,
      // color: Colors.amber,
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.01,
            ),
            Container(
              height: height * 0.1,
              child: Image.asset(
                "assets/images/logo.png",
              ),
            ),
            SizedBox(
              height: height * 0.03,
            ),
            Text(
              "Sock-Chat",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Container roomButton(
    double height,
    double width,
    GestureTapCallback? tap,
  ) {
    return Container(
      height: height * 0.15,
      width: width * 0.45,
      child: InkWell(
        onTap: tap,
        child: Center(
          child: Container(
            alignment: Alignment.center,
            height: height * 0.09,
            width: width * 0.43,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Start Chat ",
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 25,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future copyRoomID(String roomID) async {
    FlutterClipboard.copy(roomID).then((value) {
      showToast('copied');
    });
  }

  static Future joinRoomAlert(
    BuildContext context,
    TextEditingController roomIDController,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          backgroundColor: Colors.white,
          title: Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.05,
                width: MediaQuery.of(context).size.width * 0.1,
                child: Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Graphik",
                            fontStyle: FontStyle.normal,
                            fontSize: 20.4),
                        text: "Join Room",
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Container(
                  height: MediaQuery.of(context).size.height * 0.12,
                  // color: Colors.amber,
                  child: Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.034),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: roomIDController,
                      onChanged: (roomId) {
                        // value.setRoomId(roomId);
                      },
                      decoration: InputDecoration(
                        hintText: "Enter Name",
                        hintStyle: TextStyle(fontSize: 16),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            width: 2,
                            style: BorderStyle.solid,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                InkWell(
                  onTap: () {
                    String _userName = roomIDController.text.trim();
                    Navigator.pop(context);
                    print(_userName);
                    if (_userName == "") {
                      showToast("Please Enter your Name");
                      return;
                    }
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return HomePage(
                          username: _userName,
                        );
                      },
                    )).then((value) {
                      roomIDController.clear();
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width * 0.28,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(80.0)),
                    child: Text(
                      "Join",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Montserrat",
                          fontStyle: FontStyle.normal,
                          fontSize: 14.0),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
