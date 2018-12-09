import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/ScaleGestureDetector.dart';

class CustomizedBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 45, left: 15),
      child: ScaleGestureDetector(
        child: Image.asset('assets/icons/arrow-down-black.png'),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
