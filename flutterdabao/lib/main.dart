import 'dart:developer';
import 'package:observable/observable.dart';

import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/LoginSignup/LoginPage.dart';
import 'package:flutterdabao/LoginSignup/SplashScreen.dart';
import 'package:flutterdabao/MainTabBar.dart';
import 'package:flutterdabao/ReactiveHelpers/MutableProperty.dart';

import 'package:firebase_auth/firebase_auth.dart';


void main() { 
  
  
runApp(new MyApp());}
    
    class MyApp extends StatelessWidget {
      // This widget is the root of your application.

    
    
      @override
      Widget build(BuildContext context) {


        return new MaterialApp(
          title: 'Flutter Demo',
          theme: new ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
            // counter didn't reset back to zero; the application is not restarted.
            primarySwatch: ColorHelper.dabaoOrangeMaterial,
          ),
          home: _handleCurrentScreen(),
    
          
        );
      }
    
// Handles Authentication State 
      Widget _handleCurrentScreen() {
        return new StreamBuilder<FirebaseUser>(
          stream: FirebaseAuth.instance.onAuthStateChanged,
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
                  return new SplashScreenPage();
            } else {
              if (snapshot.hasData) {
                return new MainTabBarPage(title:"Dabao");
              }
                return new LoginPage();
            }
          }
        );
    }
    }
  
  
  void temp(String event) {
    
}
