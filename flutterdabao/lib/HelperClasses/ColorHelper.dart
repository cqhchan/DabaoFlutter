import 'dart:ui';

import 'package:flutter/material.dart';

class ColorHelper {
  static int _dabaoOrangeHexCode = 0xFFF5A510;

  static Color dabaoOrange = rgba(0xF5, 0xA5, 0x10);

  static MaterialColor dabaoOrangeMaterial = MaterialColor(
    _dabaoOrangeHexCode,
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
  static Color rgba(int r, int b, int g, [int a = 100]) {
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

