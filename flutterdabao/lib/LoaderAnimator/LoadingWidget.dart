import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => new _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: ColorHelper.dabaoOffWhiteF5,
          body: Center(
        child: CircularProgressIndicator(
                      value: null,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(ColorHelper.dabaoOrange),
                      strokeWidth: 7.0,
                    ),
      ),
    );
    
  }
}
