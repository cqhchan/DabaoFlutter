import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Headers/FloatingHeader.dart';
import 'package:flutterdabao/CustomWidget/ScaleGestureDetector.dart';

import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
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
      _opacityProperty.value = max(min((_controller.offset / 150), 1.0), 0.0);
    });
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
                    "How can we help you today?",
                    style: FontHelper.semiBold18Black,
                  ),
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                  child: Row(
                    children: <Widget>[
                      ScaleGestureDetector(
                        onTap: ()  {
                          print("testing");
                          FirebaseAuth.instance.signOut();
                        },
                        child: Container(
                          height: 95,
                          width: 95,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 1),
                                    color: Colors.black.withOpacity(0.5),
                                    spreadRadius: 0.1,
                                    blurRadius: 2.0)
                              ],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18.0))),
                        ),
                      ),
                      Container(width: 30,),
                      ScaleGestureDetector(
                        child: Container(
                          height: 95,
                          width: 95,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 1),
                                    color: Colors.black.withOpacity(0.5),
                                    spreadRadius: 0.1,
                                    blurRadius: 2.0)
                              ],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18.0))),
                        ),
                      ),
                    ],
                  ),
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
                    child: Image.asset(
                      "assets/icons/profile_icon.png",
                      scale: 0.8,
                    ),
                  )))
        ],
      );

  Stack balanceStack(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.width * 1.02,
          decoration: new BoxDecoration(
              image: new DecorationImage(
                  colorFilter: ColorFilter.mode(
                      ColorHelper.rgba(0xD8, 0xD8, 0xD8, 20), BlendMode.darken),
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
