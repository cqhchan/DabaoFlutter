import 'package:flutter/material.dart';

class CustomizedBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        // padding: EdgeInsets.only(top: 30.0),
        child: RawMaterialButton(
          constraints: BoxConstraints(minWidth: 60.0, minHeight: 20.0),
          padding: EdgeInsets.only(top: 40.0),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Image.asset('assets/icons/arrow-down-black.png'),
        ),
      ),
    );
  }
}
