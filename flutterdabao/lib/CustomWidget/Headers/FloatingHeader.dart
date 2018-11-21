import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';

class FloatingHeader extends StatelessWidget {
  final String title;
  final GestureDetector leftImage;
  final GestureDetector rightImage;
  final TextStyle textStyle;
  final Color backgroundColor;
  final double opacity;

  FloatingHeader(
      {Key key,
      this.backgroundColor = Colors.white,
      this.title,
      this.textStyle = FontHelper.headerTextStyle,
      this.leftImage,
      this.rightImage,
      this.opacity = 1.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Container(
        child: Stack(
      children: <Widget>[
        new Positioned.fill(
            child: Opacity(
          opacity: this.opacity,
          child: Container(
            decoration: BoxDecoration(
                color: backgroundColor,
                boxShadow: [BoxShadow(color: Colors.black, blurRadius: 4.0)]),
          ),
        )),
        new SafeArea(
          left: true,
          top: true,
          bottom: false,
          child: Container(
              height: 50.0,
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              alignment: Alignment.bottomLeft,
              child: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  Container(
                    child: leftImage == null
                        ? Container(
                            height: 20.0,
                            width: 20.0,
                          )
                        : leftImage,
                  ),
                  Expanded(
                    child: title == null
                        ? Container()
                        : Text(
                            title,
                            textAlign: TextAlign.center,
                            style: textStyle,
                          ),
                  ),
                  Container(
                    child: rightImage == null
                        ? Container(
                            height: 20.0,
                            width: 20.0,
                          )
                        : rightImage,
                  )
                ],
              )),
        ),
      ],
    ));
  }
}
