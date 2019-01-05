import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/LoaderAnimator/LoadingWidget.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/LoginSignup/LoginPage.dart';
import 'package:flutterdabao/LoginSignup/ProcessingPage.dart';
import 'package:flutterdabao/Model/User.dart';

class DabaoApp extends StatelessWidget {
  // Add in all set up etc needed
  DabaoApp() {
    // debugPaintSizeEnabled=true;
    ConfigHelper.instance.appDidLoad();

    var db = Firestore.instance;
    db.settings(timestampsInSnapshotsEnabled: true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: ConfigHelper.instance.navigatorKey,
      title: 'DABAO',
      theme: ThemeData(fontFamily: "SF_UI_Display", primarySwatch: ColorHelper.dabaoOrangeMaterial,brightness: Brightness.light,),
      home: _handleCurrentScreen(),
    );
  }

  // Handles Authentication State
  // Navigation logic
  Widget _handleCurrentScreen() {
    return StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage();
          } else {
            if (snapshot.hasData) {
              //This line of code sets the current user in ConfigHelper
              User user = User.fromAuth(snapshot.data);
              //Check if its logged in
              
              return ProcessingPage(user);
            } else {
              return Navigator(onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute(builder: (context) {
                  //return LoginPage();
                  return LoginPage();
                });
              });
            }
          }
        });
  }

 
}
