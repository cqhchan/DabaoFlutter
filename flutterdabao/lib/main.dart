import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:observable/observable.dart';

import 'package:flutterdabao/app.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/LoginSignup/LoginPage.dart';
import 'package:flutterdabao/LoginSignup/SplashScreen.dart';
import 'package:flutterdabao/MainTabBar.dart';
import 'package:flutterdabao/ReactiveHelpers/MutableProperty.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(DabaoApp());
}