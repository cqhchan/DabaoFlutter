import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutterdabao/style/home_style.dart';
import 'package:flutterdabao/initial/login.dart';
import 'package:flutterdabao/initial/loading.dart';
import 'package:flutterdabao/default.dart';

class DabaoApp extends StatelessWidget {
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
              return Default();
            }
            return LoginPage();
          }
        });
  }
}