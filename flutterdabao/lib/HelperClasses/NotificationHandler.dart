import 'package:flutter/material.dart';
import 'package:flutterdabao/ChatPage/ChatPage.dart';
import 'package:flutterdabao/CustomWidget/FadeRoute.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/Model/Channels.dart';
import 'package:flutterdabao/ViewOrdersTabPages/DabaoerChat.dart';
import 'package:flutterdabao/ViewOrdersTabPages/TabBarPage.dart';

const String modeChannel = "NEWMESSAGE";

const String channelIDKey = "channelID";

const String modeAcceptedOrder = "ORDERACCEPTED";
const String modeCompletedOrder = "ORDERCOMPLETED";
const String modeNewPotentialOrder = "POTENTIALORDER";

handleNotificationForResumeAndLaunch(map) async {
  print("testing 12345" + map.toString());

  if (map.containsKey("mode")) {
    String mode = map["mode"];

    switch (mode) {
      case modeChannel:
        if (map.containsKey(channelIDKey)) {
          String channelID = map[channelIDKey];
          Channel channel = Channel.fromUID(channelID);

          GlobalKey<ConversationState> key = getCurrentKey();

          if (key == null ||
              key.currentState == null ||
              key.currentState.widget == null ||
              key.currentState.widget.channel.uid != channelID) {
            GlobalKey<ConversationState> newKey =
                GlobalKey<ConversationState>(debugLabel: channelID);

            ConfigHelper.instance.navigatorKey.currentState
                .push(MaterialPageRoute(builder: (context) {
              print("it seems to be calling twice");
              return Conversation(
                key: newKey,
                channel: channel,
              );
            }));
          }
        }

        break;

      case modeNewPotentialOrder:
        ConfigHelper.instance.navigatorKey.currentState
            .push(FadeRoute(widget: TabBarPage()));
        break;
    }
  }
}

handleNotificationForOnMessage(map) async {
  Map<String, dynamic> data =
      Map.castFrom<dynamic, dynamic, String, dynamic>(map["data"]);
  Map<String, dynamic> notification =
      Map.castFrom<dynamic, dynamic, String, dynamic>(map["notification"]);

  String title = notification["title"];
  String body = notification["body"];
  print("testing it came here" + title);

  if (data.containsKey("mode")) {
    String mode = data["mode"];

    switch (mode) {
      case modeChannel:
        if (data.containsKey(channelIDKey)) {
          String channelID = data[channelIDKey];
          Channel channel = Channel.fromUID(channelID);
          GlobalKey<ConversationState> key = getCurrentKey();

          if (key == null ||
              key.currentState == null ||
              key.currentState.widget == null ||
              key.currentState.widget.channel.uid != channelID)
            print("Not same channel");
          else {
            print("same channel");
          }
        }

        break;

      case modeNewPotentialOrder:
        // print("testing it came here");
        // await ConfigHelper.instance.navigatorKey.currentState
        //     .push(FadeRoute(widget: TabBarPage()));
        break;
    }
  }
}
