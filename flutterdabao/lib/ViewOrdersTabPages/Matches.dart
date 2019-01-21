import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/ViewOrdersTabPages/OrderList.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Matches extends StatefulWidget {
  final DabaoRoute.Route route;
  final VoidCallback moveToConfirmCallback;

  Matches({Key key, @required this.route, this.moveToConfirmCallback})
      : super(key: key);

  @override
  MatchesState createState() {
    return new MatchesState();
  }
}

class MatchesState extends State<Matches> with HavingSubscriptionMixin {
  MutableProperty<List<Order>> listOfPotentialMatches = MutableProperty(List());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    listOfPotentialMatches = widget.route.listOfPotentialOrders;
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text(
          'MATCHES',
          style: FontHelper.header3TextStyle,
        ),
      ),
      body: OrderList(
        onCompleteCallBack: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Order Accepted!"),
                  content: Text("Continue browsing matches?"),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text(
                        "No",
                        style: FontHelper.regular(Colors.black, 14.0),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        widget.moveToConfirmCallback();
                      },
                    ),
                    new FlatButton(
                      child: new Text(
                        "Yes, stay",
                        style: FontHelper.regular(Colors.black, 14.0),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
        },
        context: context,
        route: widget.route,
        input: listOfPotentialMatches.producer,
        location: widget.route.deliveryLocation.value
            .map((geopoint) => LatLng(geopoint.latitude, geopoint.longitude))
            .first,
        refresh: (context) async {
          try {
            final result = await InternetAddress.lookup('google.com');
            if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
              setState(() {
                listOfPotentialMatches = widget.route.refreshPotentialOrders();
              });

              return listOfPotentialMatches.producer
                  .where((list) => list != null)
                  .map((first) => null)
                  .first;
            }

            print('not connected');
            final snackBar = SnackBar(
                content: Text(
                    'An Error has occured. Please check your network connectivity'));
            Scaffold.of(context).showSnackBar(snackBar);
          } on SocketException catch (_) {
            print('not connected');
            final snackBar = SnackBar(
                content: Text(
                    'An Error has occured. Please check your network connectivity'));
            Scaffold.of(context).showSnackBar(snackBar);
          }

          return Future.delayed(Duration(seconds: 1));
        },
      ),
    );
  }
}
