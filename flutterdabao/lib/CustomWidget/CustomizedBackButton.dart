import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Headers/FloatingHeader.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';

class CustomizedBackButton extends StatelessWidget {
  
  
  @override
  Widget build(BuildContext context) {
    return FloatingHeader(
      opacityProperty: MutableProperty<double>(0.0),
      leftButton: GestureDetector(
        child: Image.asset(
          "assets/icons/arrow-left-round.png",
        ),
        onTap: (){
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
