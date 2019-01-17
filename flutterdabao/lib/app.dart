import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/FadeRoute.dart';
import 'package:flutterdabao/CustomWidget/LoaderAnimator/LoadingWidget.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/NotificationHandler.dart';
import 'package:flutterdabao/LoginSignup/LoginPage.dart';
import 'package:flutterdabao/LoginSignup/ProcessingPage.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/ViewOrdersTabPages/TabBarPage.dart';

class DabaoApp extends StatefulWidget {
  // Add in all set up etc needed

  @override
  DabaoAppState createState() {
    return new DabaoAppState();
  }
}

class DabaoAppState extends State<DabaoApp> with HavingSubscriptionMixin {
  FirebaseMessaging _firebaseMessaging;

  Stream<FirebaseUser> authState = FirebaseAuth.instance.onAuthStateChanged;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // debugPaintSizeEnabled=true;
    ConfigHelper.instance.appDidLoad();

    var db = Firestore.instance;
    db.settings(timestampsInSnapshotsEnabled: true);
    _firebaseMessaging = FirebaseMessaging();

    disposeAndReset();
    if (Platform.isIOS) iOS_Permission();
    firebaseCloudMessagingListeners();

  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  void firebaseCloudMessagingListeners() async {
    subscription.add(
        ConfigHelper.instance.currentUserProperty.producer.listen((user) async {
      if (user != null) {
        await _firebaseMessaging.getToken().then((token) {
          user.setToken(token);
        });
      }
    }));

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print("testing onMessage");
        FirebaseAuth.instance.currentUser().then((user) {
          if (user != null) {
            handleNotificationForOnMessage(message);
          }
        });
      },
      onResume: (Map<String, dynamic> message) {
        print("testing onResume");

        FirebaseAuth.instance.currentUser().then((user) {
          if (user != null) {
            handleNotificationForResumeAndLaunch(message);
          }
        });
      },
      onLaunch: (Map<String, dynamic> message) {
        print("testing onLaunch");

        FirebaseAuth.instance.currentUser().then((user) {
          if (user != null) {
            handleNotificationForResumeAndLaunch(message);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: ConfigHelper.instance.navigatorKey,
      title: 'DABAO',
      theme: ThemeData(
        fontFamily: "SF_UI_Display",
        primarySwatch: ColorHelper.dabaoOrangeMaterial,
        brightness: Brightness.light,
      ),
      builder: (context, child) {
        return MediaQuery(
          child: child,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      home:  _handleCurrentScreen(),
    );
  }

  Key loginPageKey = Key("loginPageKey");
  Key processingPageKey = Key("processingPageKey");

  Widget _handleCurrentScreen() {
    return StreamBuilder<FirebaseUser>(
        stream: authState,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage();
          } else {
            if (snapshot.hasData) {
              //This line of code sets the current user in ConfigHelper
              User user = User.fromAuth(snapshot.data);
              //Check if its logged in

              return ProcessingPage(user: user, key: processingPageKey);
            } else {
              return Navigator(onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute(builder: (context) {
                  //return LoginPage();
                  return LoginPage(key: loginPageKey);
                });
              });
            }
          }
        });
  }
}
