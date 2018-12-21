import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterdabao/CreateOrder/OrderNow.dart';
import 'package:flutterdabao/CustomWidget/Headers/FloatingHeader.dart';
import 'package:flutterdabao/CustomWidget/FadeRoute.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/LocationHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/Home/BalanceCard.dart';
import 'package:flutterdabao/Model/User.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => new _Home();
}

class _Home extends State<Home> {
  ScrollController _controller = ScrollController();
  MutableProperty<double> _opacityProperty = MutableProperty(0.0);
  _Home() {
    _controller.addListener(() {
      _opacityProperty.value = max(min((_controller.offset / 150.0), 1.0), 0.0);
    });
  }

  @override
  void initState() {
    super.initState();

    ConfigHelper.instance.startListeningToCurrentLocation(
        LocationHelper.instance.softAskForPermission());
  }

  @override
  Widget build(BuildContext context) => new Stack(
        children: <Widget>[
          new Scaffold(
            backgroundColor: ColorHelper.dabaoOffWhiteF5,
            body: ListView(
              controller: _controller,
              children: <Widget>[
                //First Widget consisting of Bg, and balance
                balanceStack(context),

                Container(
                  child: Text(
                    "How can we serve you today?",
                    style: FontHelper.semiBold18Black,
                  ),
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                  child: Wrap(
                    spacing: 25.0,
                    children: <Widget>[
                      //Dabaoee
                      squardCard('assets/icons/person.png', 'Dabaoee',
                          'I want to Order', () {
                        Navigator.push(
                          context,
                          FadeRoute(widget: OrderNow()),
                        );
                      }),
                      //Dabaoer

                      squardCard('assets/icons/bike.png', 'Dabaoer',
                          'I want to Deliver', () {
                      }),
                      //ChatBox
                    ],
                  ),
                ),
                Container(
                  child: Text(
                    "Notifications",
                    style: FontHelper.semiBold18Black,
                  ),
                  padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0.0),
                ),
              ],
            ),
          ),
          // AppBar Widget
          new Material(
              type: MaterialType.transparency,
              child: FloatingHeader(
                  backgroundColor: Colors.white,
                  opacityProperty: _opacityProperty,
                  leftButton: GestureDetector(
                    child: Container(
                      height: 40.0,
                      width: 40.0,
                      child: Image.asset(
                        "assets/icons/profile_icon.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                  )))
        ],
      );

  Container squardCard(
    String imagePath,
    String title,
    String body,
    VoidCallback onPressed,
  ) {
    return Container(
      child: RaisedButton(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
        color: Colors.white,
        elevation: 4.0,
        disabledElevation: 4.0,
        highlightElevation: 4.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18.0))),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(height: 40, width: 40, child: Image.asset(imagePath)),
            SizedBox(height: 2),
            Text(
              title,
              style: FontHelper.bold14Black,
            ),
            Text(
              body,
              style: FontHelper.regular14Black,
            ),
          ],
        ),
      ),
      height: 95.0,
      width: 95.0,
    );
  }

  Stack balanceStack(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.width * 1.02,
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  colorFilter: ColorFilter.mode(
                      ColorHelper.rgbo(0xD8, 0xD8, 0xD8, 20), BlendMode.darken),
                  image: new AssetImage("assets/images/splashbg.png"),
                  fit: BoxFit.fitWidth)),
        ),
        Positioned(
            bottom: 45.0,
            child: StreamBuilder<User>(
                stream: ConfigHelper.instance.currentUserProperty.producer,
                builder: (BuildContext context, user) {
                  return BalanceCard(user);
                }))
      ],
    );
  }
}
