import 'package:flutter/material.dart';

class CustomizedBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: FlatButton(
          padding: EdgeInsets.only(top: 20.0),
          // padding: EdgeInsets.only(top: 60.0),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Image.asset('assets/icons/arrow-down-black.png'),
        ),
      ),
    );
  }
}
