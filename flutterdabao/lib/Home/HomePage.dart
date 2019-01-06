import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/ChatPage/ChatPage.dart';
import 'package:flutterdabao/CreateOrder/OrderNow.dart';
import 'package:flutterdabao/CreateRoute/RouteOverview.dart';
import 'package:flutterdabao/CustomWidget/Headers/FloatingHeader.dart';
import 'package:flutterdabao/CustomWidget/FadeRoute.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/LocationHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Home/BalanceCard.dart';
import 'package:flutterdabao/Model/DabaoerReward.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;
import 'package:flutterdabao/Rewards/RewardsTab.dart';
import 'package:flutterdabao/ViewOrdersTabPages/TabBarPage.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutterdabao/HelperClasses/NotificationHandler.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> with AutomaticKeepAliveClientMixin{
  FirebaseMessaging _firebaseMessaging;

  ScrollController _controller = ScrollController();
  MutableProperty<double> _opacityProperty = MutableProperty(0.0);
  _Home() {
    _controller.addListener(() {
      _opacityProperty.value =
          math.max(math.min((_controller.offset / 150.0), 1.0), 0.0);
    });
  }

  @override
  void initState() {
    super.initState();

    ConfigHelper.instance.startListeningToCurrentLocation(
        LocationHelper.instance.softAskForPermission());

    //Firebase Push  Notifications
    _firebaseMessaging = FirebaseMessaging();

    if (Platform.isIOS) iOS_Permission();

    firebaseCloudMessaging_Listeners();
  }

  void firebaseCloudMessaging_Listeners() async {
    await _firebaseMessaging.getToken().then((token) {
      if (ConfigHelper.instance.currentUserProperty.value != null)
        ConfigHelper.instance.currentUserProperty.value.setToken(token);
    });

        print("firebaseCloudMessaging_Listeners 0");

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("Notification came here 1");
        print("onMessage " + message.toString());
      },
      onResume: (Map<String, dynamic> message) async {
                print("Notification came here 2");
        await ConfigHelper.instance.navigatorKey.currentState.push(FadeRoute(widget: TabBarPage()));

        // print("onResume " + message.toString());
        // await handleNotificationForResumeAndLaunch(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("Notification came here 3");
        // print("onLaunch " + message.toString());
        ConfigHelper.instance.navigatorKey.currentState.push(FadeRoute(widget: TabBarPage()));

        // await handleNotificationForResumeAndLaunch(message);
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { 
    
    super.build(context);
    
    return Scaffold(
        backgroundColor: ColorHelper.dabaoOffWhiteF5,
        body: Stack(children: <Widget>[
          ListView(
            controller: _controller,
            children: <Widget>[
              //First Widget consisting of Bg, and balance

              SafeArea(
                child: Container(
                  margin: EdgeInsets.only(top: 50.0),
                  child: Text(
                    "What would you like to do today?",
                    style: FontHelper.regular(ColorHelper.dabaoOffGrey70, 22),
                  ),
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 30.0),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 25,
                  spacing: 25.0,
                  children: <Widget>[
                    //Dabaoee
                    squardCard(
                        'assets/icons/person.png', 'Dabaoee', 'I want to Order',
                        () {
                      Navigator.push(
                        context,
                        FadeRoute(widget: OrderNow()),
                      );
                    }),
                    //Dabaoer
                    squardCard(
                        'assets/icons/bike.png', 'Dabaoer', 'I want to Deliver',
                        () {
                      Navigator.push(
                        context,
                        FadeRoute(widget: RouteOverview()),
                      );
                    }),
                  ],
                ),
              ),
              balanceCardStream(context),

              Container(
                child: Text(
                  "Notifications",
                  style: FontHelper.semiBold18Black,
                ),
                padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0.0),
              ),
            ],
          ),
          // AppBar Widget
          Material(
            type: MaterialType.transparency,
            child: FloatingHeader(
              header: StreamBuilder<String>(stream: ConfigHelper
                  .instance.currentUserProperty.producer
                  .switchMap((user) {
                if (user == null) return Observable.just("");
                return user.name;
              }), builder: (context, snap) {
                if (!snap.hasData) return Offstage();
                return Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                        padding: EdgeInsets.only(top: 10.0, left: 10.0),
                        child: Text(
                          "Welcome back, ${snap.data}",
                          overflow: TextOverflow.ellipsis,
                          style: FontHelper.regular(
                              ColorHelper.dabaoOffGrey70, 14),
                        )));
              }),
              backgroundColor: Colors.white,
              opacityProperty: _opacityProperty,
              rightButton: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    FadeRoute(widget: ChatPage()),
                  );
                },
                child: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorHelper.dabaoOrange,
                        image: new DecorationImage(
                            fit: BoxFit.scaleDown,
                            image: new AssetImage(
                                'assets/icons/chat_white.png')))),
              ),
              leftButton: Container(
                height: 40.0,
                width: 40.0,
                child: GestureDetector(
                  onTap: () {},
                  child: StreamBuilder<String>(
                    stream: ConfigHelper
                        .instance.currentUserProperty.value.thumbnailImage,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Image.asset(
                          'assets/icons/profile_icon.png',
                          fit: BoxFit.fill,
                        );
                      }
                      return GestureDetector(
                        onLongPress: () async {
                          FirebaseAuth.instance.signOut();
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data),
                          radius: 20,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          StreamBuilder<List>(
            stream:
                ConfigHelper.instance.currentUserOpenRoutesProperty.producer,
            builder: (context, snap) {
              if (!snap.hasData || snap.data.length == 0)
                return Container();
              else
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      FadeRoute(widget: TabBarPage()),
                    );
                  },
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.yellow, boxShadow: [
                        BoxShadow(
                          offset: Offset(0.0, 1.0),
                          color: Colors.grey,
                          blurRadius: 5.0,
                        )
                      ]),
                      child: SafeArea(
                        top: false,
                        child: Container(
                          padding: EdgeInsets.only(left: 20.0),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "View your Routes (${snap.data.length})",
                                  style: FontHelper.semiBold14Black,
                                ),
                              ),
                              Expanded(
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: EdgeInsets.only(bottom: 4.0),
                                      height: 19.0,
                                      width: 24.0,
                                      child: Transform(
                                        transform:
                                            Matrix4.rotationZ(math.pi / 2),
                                        child: Image.asset(
                                            "assets/icons/arrow_left_icon.png"),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
            },
          )
        ]),
      );
  }

  Container squardCard(
    String imagePath,
    String title,
    String body,
    VoidCallback onPressed,
  ) {
    return Container(
      child: RaisedButton(
        padding: EdgeInsets.fromLTRB(10, 18, 10, 10),
        color: Colors.white,
        elevation: 4.0,
        disabledElevation: 4.0,
        highlightElevation: 4.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(height: 40, width: 40, child: Image.asset(imagePath)),
            SizedBox(height: 2),
            Text(
              title,
              style: FontHelper.bold14Black,
            ),
            Expanded(
              child: Container(),
            ),
            Text(
              body,
              style: FontHelper.regular(Colors.black, 12.0),
            ),
          ],
        ),
      ),
      height: 120.0,
      width: 120.0,
    );
  }

  StreamBuilder balanceCardStream(BuildContext context) {
    return StreamBuilder<User>(
        stream: ConfigHelper.instance.currentUserProperty.producer,
        builder: (BuildContext context, user) {
          return BalanceCard(user, context);
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
