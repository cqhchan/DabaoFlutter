import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

class SplashScreenPage extends StatefulWidget {

  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenPage>
    with SingleTickerProviderStateMixin {


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        color: Colors.red,
      ),
    );
  }
}

//ColorHelper.dabaoOrangeMaterial