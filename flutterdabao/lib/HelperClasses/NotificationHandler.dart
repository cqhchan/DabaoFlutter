import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterdabao/Balance/Transaction.dart';
import 'package:flutterdabao/Chat/Conversation.dart';
import 'package:flutterdabao/Chat/Inbox.dart';
import 'package:flutterdabao/CreateOrder/OrderNow.dart';
import 'package:flutterdabao/CustomWidget/FadeRoute.dart';
import 'package:flutterdabao/CustomWidget/Route/DialogRoute.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:flutterdabao/Model/Channels.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/ViewOrders/ViewOrderPage.dart';
import 'package:flutterdabao/ViewOrdersTabPages/TabBarPage.dart';
import 'package:settings/settings.dart';

const String modeChannel = "NEWMESSAGE";

const String channelIDKey = "channelID";
const String orderIDkey = "orderID";

const String modeAcceptedOrder = "ORDERACCEPTED";
const String modeNewTransaction = "NEWTRANSACTION";

const String modeCompletedOrder = "ORDERCOMPLETED";
const String modeCancelledOrder = "ORDERCANCELLED";

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

        case modeCancelledOrder:
          if (map.containsKey(orderIDkey)) {
            String orderID = map[orderIDkey];
            Order order = Order.fromUID(orderID);

            ConfigHelper.instance.navigatorKey.currentState
                .push(MaterialPageRoute(builder: (context) {
              return DabaoeeViewOrderListPage(
                order: order,
              );
            }));

            ConfigHelper.instance.navigatorKey.currentState.push(DialogRoute(
                barrierColor: Colors.black.withOpacity(0.5),
                child: SafeArea(child: Builder(builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Order Cancelled"),
                    content: const Text(
                        "Your Order has been cancelle =( Would you like to reorder?"),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text(
                          "Reorder",
                          style: FontHelper.bold(ColorHelper.dabaoOrange, 16.0),
                        ),
                        onPressed: () async {
                          ConfigHelper.instance.navigatorKey.currentState.pop();

                          OrderHolder holder =
                              await generateHolderFromOrder(orderID);
                          ConfigHelper.instance.navigatorKey.currentState
                              .push(MaterialPageRoute(builder: (context) {
                            return OrderNow(
                              holder: holder,
                            );
                          }));
                        },
                      ),
                    ],
                  );
                }))));
          }
          break;

        case modeAcceptedOrder:
          if (map.containsKey(orderIDkey)) {
            String orderID = map[orderIDkey];
            Order order = Order.fromUID(orderID);

            ConfigHelper.instance.navigatorKey.currentState
                .push(MaterialPageRoute(builder: (context) {
              return DabaoeeViewOrderListPage(
                order: order,
              );
            }));
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
    print(map);
    Map<String, dynamic> data;
    String title;
    String body;
    if (Platform.isIOS) {
      data = Map.castFrom<dynamic, dynamic, String, dynamic>(map);
      Map<String, dynamic> alert =
          Map.castFrom<dynamic, dynamic, String, dynamic>(map["aps"]['alert']);

      title = alert["title"];
      body = alert["body"];
    } else {
      data = Map.castFrom<dynamic, dynamic, String, dynamic>(map["data"]);
      Map<String, dynamic> notification =
          Map.castFrom<dynamic, dynamic, String, dynamic>(map["notification"]);
      title = notification["title"];
      body = notification["body"];
    }

    if (data.containsKey("mode")) {
      String mode = data["mode"];

      switch (mode) {
        case modeAcceptedOrder:
          ConfigHelper.instance.navigatorKey.currentState.push(DialogRoute(
              barrierColor: Colors.black.withOpacity(0.5),
              child: SafeArea(child: Builder(builder: (BuildContext context) {
                return AlertDialog(
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

                        if (data.containsKey(orderIDkey)) {
                          String orderID = data[orderIDkey];
                          Order order = Order.fromUID(orderID);
                          ConfigHelper.instance.navigatorKey.currentState
                              .push(MaterialPageRoute(builder: (context) {
                            return DabaoeeViewOrderListPage(
                              order: order,
                            );
                          }));
                        }
                      },
                    ),
                  ],
                );
              }))));

          break;

        case modeCancelledOrder:
          ConfigHelper.instance.navigatorKey.currentState.push(DialogRoute(
              barrierColor: Colors.black.withOpacity(0.5),
              child: SafeArea(child: Builder(builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Order Cancelled"),
                  content: const Text(
                      "Your Order has been cancelle =( Would you like to reorder?"),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text(
                        "VIEW",
                        style: FontHelper.bold(ColorHelper.dabaoOrange, 16.0),
                      ),
                      onPressed: () async {
                        ConfigHelper.instance.navigatorKey.currentState.pop();

                        if (data.containsKey(orderIDkey)) {
                          String orderID = data[orderIDkey];
                          Order order = Order.fromUID(orderID);
                          ConfigHelper.instance.navigatorKey.currentState
                              .push(MaterialPageRoute(builder: (context) {
                            return DabaoeeViewOrderListPage(
                              order: order,
                            );
                          }));
                        }
                      },
                    ),
                    new FlatButton(
                      child: new Text(
                        "Reorder",
                        style: FontHelper.bold(ColorHelper.dabaoOrange, 16.0),
                      ),
                      onPressed: () async {
                        ConfigHelper.instance.navigatorKey.currentState.pop();

                        if (data.containsKey(orderIDkey)) {
                          String orderID = data[orderIDkey];
                          OrderHolder holder =
                              await generateHolderFromOrder(orderID);
                          ConfigHelper.instance.navigatorKey.currentState
                              .push(MaterialPageRoute(builder: (context) {
                            return OrderNow(
                              holder: holder,
                            );
                          }));
                        }
                      },
                    ),
                  ],
                );
              }))));

          break;

        case modeCompletedOrder:
          ConfigHelper.instance.navigatorKey.currentState.push(DialogRoute(
              barrierColor: Colors.black.withOpacity(0.5),
              child: SafeArea(child: Builder(builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Order Completed"),
                  content: const Text("Your Order has been completed!"),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text(
                        "VIEW",
                        style: FontHelper.bold(ColorHelper.dabaoOrange, 16.0),
                      ),
                      onPressed: () async {
                        ConfigHelper.instance.navigatorKey.currentState.pop();

                        ConfigHelper.instance.navigatorKey.currentState
                            .popUntil(ModalRoute.withName(
                                Navigator.defaultRouteName));

                        if (data.containsKey(orderIDkey)) {
                          String orderID = data[orderIDkey];
                          Order order = Order.fromUID(orderID);
                          ConfigHelper.instance.navigatorKey.currentState
                              .push(MaterialPageRoute(builder: (context) {
                            return DabaoeeViewOrderListPage(
                              order: order,
                            );
                          }));
                        }
                      },
                    ),
                  ],
                );
              }))));

          break;

        case modeNewTransaction:
          ConfigHelper.instance.navigatorKey.currentState.push(DialogRoute(
              barrierColor: Colors.black.withOpacity(0.5),
              child: SafeArea(child: Builder(builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(title),
                  content: Text(body),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text(
                        "VIEW",
                        style: FontHelper.bold(ColorHelper.dabaoOrange, 16.0),
                      ),
                      onPressed: () async {
                        ConfigHelper.instance.navigatorKey.currentState.pop();

                        ConfigHelper.instance.navigatorKey.currentState
                            .popUntil(ModalRoute.withName(
                                Navigator.defaultRouteName));

                        ConfigHelper.instance.navigatorKey.currentState
                            .push(MaterialPageRoute(builder: (context) {
                          return TransactionsPage();
                        }));
                      },
                    ),
                  ],
                );
              }))));

          break;
      }
    }
  });
}