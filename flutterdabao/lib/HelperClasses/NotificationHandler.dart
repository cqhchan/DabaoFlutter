import 'package:flutter/material.dart';
import 'package:flutterdabao/Chat/Conversation.dart';
import 'package:flutterdabao/Chat/Inbox.dart';
import 'package:flutterdabao/CustomWidget/FadeRoute.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/Model/Channels.dart';
import 'package:flutterdabao/ViewOrdersTabPages/TabBarPage.dart';
import 'package:settings/settings.dart';

const String modeChannel = "NEWMESSAGE";

const String channelIDKey = "channelID";

const String modeAcceptedOrder = "ORDERACCEPTED";
const String modeNewTransaction = "NEWTRANSACTION";

const String modeCompletedOrder = "ORDERCOMPLETED";
const String modeNewPotentialOrder = "POTENTIALORDER";

handleNotificationForResumeAndLaunch(map) async {
  ConfigHelper.instance.currentUserProperty.producer
      .firstWhere((user) => user != null)
      .then((user) {
    print("testing " + map.toString());

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
  });
}

handleNotificationForOnMessage(map) async {
  ConfigHelper.instance.currentUserProperty.producer
      .firstWhere((user) => user != null)
      .then((user) {
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
        case modeAcceptedOrder:
          showDialog(
              context: ConfigHelper.instance.navigatorKey.currentState.context,
              builder: (_) => new AlertDialog(
                    title: const Text("Order Accepted"),
                    content: const Text("Your Order has been accepted!"),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text(
                          "VIEW",
                          style: FontHelper.bold(ColorHelper.dabaoOrange, 16.0),
                        ),
                        onPressed: () async {
                          ConfigHelper.instance.navigatorKey.currentState
                              .popUntil(ModalRoute.withName(
                                  Navigator.defaultRouteName));
                        },
                      ),
                    ],
                  ));
          break;

        case modeNewTransaction:
          showDialog(
              context: ConfigHelper.instance.navigatorKey.currentState.context,
              builder: (_) => new AlertDialog(
                    title: Text(title),
                    content: Text(body),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text(
                          "VIEW",
                          style: FontHelper.bold(ColorHelper.dabaoOrange, 16.0),
                        ),
                        onPressed: () async {
                          ConfigHelper.instance.navigatorKey.currentState
                              .popUntil(ModalRoute.withName(
                                  Navigator.defaultRouteName));
                        },
                      ),
                    ],
                  ));
          break;
      }
    }
  });
}
