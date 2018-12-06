import 'package:flutter/material.dart';

class CustomizedBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: EdgeInsets.only(top: 30.0),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // padding: EdgeInsets.only(top: 60.0),
        // onPressed: () {
        //   Navigator.pop(context);
        // },
        // child: Image.asset('assets/icons/arrow-down-black.png'),
      ),
    );
  }
}
