import 'package:flutter/material.dart';
import 'package:sockchat/view/components/roomScreenComponents.dart';

// ignore: must_be_immutable
class RoomScreen extends StatelessWidget {
  TextEditingController roomIdController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        child: ListView(
          children: [
            SizedBox(
              height: height * 0.25,
            ),
            RoomScreenComponents.logoWidget(height),
            SizedBox(
              height: height * 0.04,
            ),
            Container(
              height: height * 0.32,
              // color: Colors.blue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height * 0.01,
                  ),
                  RoomScreenComponents.roomButton(
                    height,
                    width,
                    () async {
                      await RoomScreenComponents.joinRoomAlert(
                        context,
                        roomIdController,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
