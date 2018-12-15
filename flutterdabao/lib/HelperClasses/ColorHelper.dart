import 'dart:ui';

import 'package:flutter/material.dart';

class ColorHelper {
  static int dabaoOrangeHexCode = 0xFFF5A510;

  static const Color dabaoOrange = Color.fromRGBO(0xF5, 0xA5, 0x10, 1.0);

  static Color dabaoOffWhiteF5 = rgbo(0xF5, 0xF5, 0xF5);

  static  const Color dabaoOffGreyD8 = Color.fromRGBO(0xD8, 0xD8, 0xD8,1.0);
  static  const Color dabaoOffGrey70 = Color.fromRGBO(0x70, 0x70, 0x70,1.0);


  static const Color dabaoOffBlack4A = Color.fromRGBO(0x4A, 0x4A, 0x4A,1.0);
  static const Color dabaoOffBlack9B =  Color.fromRGBO(0x9B, 0x9B, 0x9B,1.0);

  static const Color dabaoGreyE0 = Color.fromRGBO(0xE0, 0xE0, 0xE0, 1.0);


  static MaterialColor dabaoOrangeMaterial = MaterialColor(
    dabaoOrangeHexCode,
    <int, Color>{
      50: dabaoOrange,
      100: dabaoOrange,
      200: dabaoOrange,
      300: dabaoOrange,
      400: dabaoOrange,
      500: dabaoOrange,
      600: dabaoOrange,
      700: dabaoOrange,
      800: dabaoOrange,
      900: dabaoOrange,
    },
  );

  // a is alpha from 0-100 %
  static Color rgbo(int r, int b, int g, [int a = 100]) {
    return Color.fromARGB((a * 255 / 100).round(), r, b, g);
  }
  
}

Color kBackground = Colors.white;
Color kBottomNavigator = Colors.amber;
Color kDeliverButton = Colors.grey[300];
Color kOrderButton = Colors.amber;

Color kDateTimeContainer = Colors.white;
Color kDateTimePicked = Colors.amber[200];
Color kDateTimeUnpicked = Colors.white;
Color kDateTimeUnavailable = Colors.grey[400];

Color kText = Colors.black;
Color kTab = Colors.amber;
Color kMarker = Colors.amber;


final dabaoColourScheme = ThemeData(
            primarySwatch: Colors.amber,
            scaffoldBackgroundColor: Colors.white,
            primaryColor: Colors.amber[600],
            backgroundColor: Colors.white
            );

final name = 'Chris';

