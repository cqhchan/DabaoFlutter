import 'package:flutter/material.dart';
import 'package:flutterdabao/ChatPage/ChatPage.dart';
import 'package:flutterdabao/CustomWidget/FadeRoute.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/ViewOrdersTabPages/TabBarPage.dart';

const String modeChannel = "NEWMESSAGE";
const String modeAcceptedOrder = "ORDERACCEPTED";
const String modeCompletedOrder = "ORDERCOMPLETED";
const String modeNewPotentialOrder = "POTENTIALORDER";

handleNotificationForResumeAndLaunch(map) async {
  NavigatorState state = ConfigHelper.instance.navigatorKey.currentState;

  print("testing notificationc called");
  if (map.containsKey("mode")) {
    String mode = map["mode"];

    switch (mode) {
      case modeChannel:
        // await state.push(FadeRoute(widget: ChatPage()));
        await ConfigHelper.instance.navigatorKey.currentState.push(FadeRoute(widget: TabBarPage()));

        break;

      case modeNewPotentialOrder:
        await ConfigHelper.instance.navigatorKey.currentState.push(FadeRoute(widget: TabBarPage()));
        break;
    }
  }
}
