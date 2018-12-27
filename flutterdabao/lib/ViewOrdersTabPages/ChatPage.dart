import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/User.dart';

class ChatPage extends StatefulWidget {

  final Order order;

  const ChatPage({Key key, this.order}) : super(key: key);

  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            size: 26,
            color: Colors.black,
          ),
        ),
        elevation: 0.0,
        title: StreamBuilder<User>(
      stream: widget.order.creator
          .where((uid) => uid != null)
          .map((uid) => User.fromUID(uid)),
      builder: (context, user) {
        if (!user.hasData) return Offstage();
        return Row(
          children: <Widget>[
            StreamBuilder<String>(
              stream: user.data.thumbnailImage,
              builder: (context, user) {
                if (!user.hasData) return Offstage();
                return CircleAvatar(
                  backgroundImage: NetworkImage(user.data),
                  radius: 14.5,
                );
              },
            ),
            SizedBox(
              width: 10,
            ),
            StreamBuilder<String>(
              stream: user.data.name,
              builder: (context, user) {
                if (!user.hasData) return Offstage();
                return Text(
                  user.hasData ? user.data : "Error",
                  style: FontHelper.semiBold16Black,
                );
              },
            ),
          ],
        );
      },
    ),
      ),
      body: Center(),
    );
  }
}