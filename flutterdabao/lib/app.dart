import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterdabao/CustomWidget/LoaderAnimator/LoadingWidget.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/Home/HomePage.dart';
import 'package:flutterdabao/Model/User.dart';

import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/LoginSignup/LoginPage.dart';

class DabaoApp extends StatelessWidget {
  // Add in all set up etc needed
  DabaoApp() {
    // debugPaintSizeEnabled=true;
    ConfigHelper.instance.appDidLoad();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DABAO',
      theme: ThemeData(fontFamily: "SF_UI_Display", primarySwatch: ColorHelper.dabaoOrangeMaterial,brightness: Brightness.light,),
      home: _handleCurrentScreen(),
    );
  }

  // Handles Authentication State
  Widget _handleCurrentScreen() {
    return StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage();
          } else {
            if (snapshot.hasData) {
              // If Logged in, load user from FirebaseAuth
              //TODO add in check if user has completed profile creation else bring to profile creation;
              User.fromAuth(snapshot.data);
              return Home();
            }

            return LoginPage();
          }
        });
  }
}
