import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sockchat/controller/chatController.dart';
import 'package:sockchat/view/screens/homepage.dart';

void main() {
  runApp(MyApp());
}

void showToast(String msgs) {
  Fluttertoast.showToast(
      msg: msgs,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<SingleChildWidget> providers = [
      ChangeNotifierProvider<ChatMessageProvider>(
        create: (_) => ChatMessageProvider(),
      ),
      ChangeNotifierProvider<SendFileProvider>(
        create: (_) => SendFileProvider(),
      ),
    ];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MultiProvider(
        providers: providers,
        child: HomePage(),
      ),
    );
  }
}
