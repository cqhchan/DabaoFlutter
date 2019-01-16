import 'package:flutter/material.dart';
import 'package:flutterdabao/Chat/Inbox.dart';
import 'package:flutterdabao/CustomWidget/FadeRoute.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';

class ChatNavigationButton extends StatefulWidget {
  final Color bgColor;

  const ChatNavigationButton({Key key, this.bgColor = Colors.white})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ChatNavigationButtonState();
  }
}

class ChatNavigationButtonState extends State<ChatNavigationButton> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return // Show chat NavigationButton
        GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          SlideUpRoute(widget: ChatPage()),
        );
      },
      child: Container(
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment(0.0, 0.0),
            children: <Widget>[
              Align(
                  alignment: Alignment.center,
                  child: Container(
                      padding: EdgeInsets.only(right: 15, left: 15),
                      child: Icon(Icons.inbox))),
              Align(
                  alignment: Alignment.centerRight,
                  child: StreamBuilder<int>(
                    stream: ConfigHelper
                        .instance.currentUserChannelProperty.producer
                        .map((channels) {
                      return channels
                          .map((channel) => channel.unreadMessages.value == null
                              ? 0
                              : channel.unreadMessages.value)
                          .reduce((a, b) => a + b);
                    }),
                    builder: (BuildContext context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data == null ||
                          snapshot.data == 0) return Offstage();

                      return Container(
                        padding: EdgeInsets.only(left: 3, right: 3),
                        margin: EdgeInsets.only(left: 15, bottom: 20),
                        height: 22,
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: widget.bgColor, width: 2.0),
                            color: ColorHelper.dabaoTealColor,
                            borderRadius: BorderRadius.circular(11)),
                        child: ConstrainedBox(
                          child: Center(
                              child: Text(
                            snapshot.data > 99
                                ? "99+"
                                : snapshot.data.toString(),
                            style: FontHelper.regular(Colors.white, 10),
                          )),
                          constraints: BoxConstraints(minWidth: 12),
                        ),
                      );
                    },
                  ))
            ],
          )),
    );
  }
}
