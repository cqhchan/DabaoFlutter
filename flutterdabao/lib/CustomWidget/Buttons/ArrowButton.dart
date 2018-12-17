import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';

class ArrowButton extends StatelessWidget{
  
  final String title;
  final VoidCallback onPressedCallback;

  ArrowButton({@required this.title, this.onPressedCallback, });
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FlatButton(
        color: ColorHelper.dabaoOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      title,
                      style: FontHelper.semiBold(Colors.black, 14.0),
                    ))),
            Image.asset("assets/icons/arrow_right_white_circle.png")
          ],
        ),
        onPressed: onPressedCallback
      );
  }


}