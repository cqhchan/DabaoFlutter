import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/Model/User.dart';

import 'package:flutterdabao/style/home_style.dart';
import 'package:flutterdabao/initial/login.dart';
import 'package:flutterdabao/initial/loading.dart';
import 'package:flutterdabao/default.dart';

class DabaoApp extends StatelessWidget {

  // Add in all set up etc needed 
  DabaoApp(){

    debugPaintSizeEnabled=true;
    ConfigHelper.instance.appDidLoad();


  }

  @override
  Widget build(BuildContext context) {

    

    return MaterialApp(
      title: 'DABAO',
      theme: dabaoColourScheme,
      home: _handleCurrentScreen(),
      // initialRoute: '/loginpage',
      routes: <String, WidgetBuilder>{
        '/defaultpage': (BuildContext context) => Default(),
        '/loginpage': (BuildContext context) => LoginPage(),
      },
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
              return Default();
            }
            
            return LoginPage();
          }
        });
  }
}