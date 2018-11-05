import 'dart:developer';
import 'package:flutterdabao/app.dart';
import 'package:observable/observable.dart';

import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
// import 'package:flutterdabao/LoginSignup/LoginPage.dart';
import 'package:flutterdabao/LoginSignup/SplashScreen.dart';
import 'package:flutterdabao/MainTabBar.dart';
import 'package:flutterdabao/ReactiveHelpers/MutableProperty.dart';

import 'package:firebase_auth/firebase_auth.dart';

//-----------------------------------------------------------------

import 'package:flutterdabao/initial/login.dart';
import 'package:flutterdabao/default.dart';

//-----------------------------------------------------------------

// Uncomment this to do the UI only!
// void main() {
//   runApp( DabaoApp());
// }

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: ColorHelper.dabaoOrangeMaterial,
      ),
      home: _handleCurrentScreen(),
    );
  }

  // Handles Authentication State
  Widget _handleCurrentScreen() {
    return StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {

          print('first : ${snapshot.connectionState}');
          print('second : ${ConnectionState.waiting}');

          if (snapshot.connectionState == ConnectionState.active) {
            return SplashScreenPage();
          } else {
            if (snapshot.hasData) {
              return HomePage();
            }
            return LoginPage();
          }
        });
  }
}
