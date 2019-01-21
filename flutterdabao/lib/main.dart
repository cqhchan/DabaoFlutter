import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterdabao/app.dart';
import 'package:flutter/widgets.dart';

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(DabaoApp());
}
