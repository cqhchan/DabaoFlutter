import 'package:flutter/material.dart';
import 'package:flutterdabao/CreateOrder/CustomizedMap.dart';
import 'package:flutterdabao/CreateOrder/LocationCard.dart';
import 'package:flutterdabao/CreateOrder/OrderCheckoutCard.dart';
import 'package:flutterdabao/CreateOrder/OrderOverlay.dart';
import 'package:flutterdabao/CreateRoute/DoubleLocationCard.dart';
import 'package:flutterdabao/CreateRoute/DoubleLocationMap.dart';
import 'package:flutterdabao/CreateRoute/RouteOverlay.dart';
import 'package:flutterdabao/CustomWidget/Buttons/CustomizedBackButton.dart';
import 'package:flutterdabao/CustomWidget/HalfHalfPopUpSheet.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';

import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:flutterdabao/Holder/RouteHolder.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteOverview extends StatefulWidget {
  _RouteOverviewState createState() => _RouteOverviewState();
}

class _RouteOverviewState extends State<RouteOverview>
    with HavingSubscriptionMixin, SingleTickerProviderStateMixin {

  MutableProperty<bool> focusOnStart = MutableProperty<bool>(true);

  final RouteHolder holder = RouteHolder();

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    subscription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          DoubleLocationCustomizedMap(
            endSelectedLocation: holder.endDeliveryLocation,
            endSelectedLocationDescription: holder.endDeliveryLocationDescription,
            focusOnStart: focusOnStart,
            startSelectedLocation: holder.startDeliveryLocation,
            startSelectedLocationDescription: holder.startDeliveryLocationDescription,
          ),
          CustomizedBackButton(),
           DoubleLocationCard(
                  showOverlayCallback: showOverlay,
                  holder: holder, focusOnStart: focusOnStart,
                ),
          
        
        ],
      ),
    );
  }

  showOverlay() {
    showHalfBottomSheet(
        context: context,
        builder: (builder) {
          return RouteOverlay(
            holder: holder,
          );
        });
  }
}