import 'package:flutter/material.dart';
import 'package:flutterdabao/ChatPage/ChatList.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';

class ChatPage extends StatefulWidget {
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatList(
        context: context,
        user: ConfigHelper.instance.currentUserProperty,
      ),
    );
  }
}
