import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Route/OverlayRoute.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';

const Color defaultColor = Color.fromRGBO(0x33, 0x33, 0x33, 1.0);

Future<T> showInfomationDialog<T>({
  @required double x,
  @required double y,
  @required String title,
  @required String subTitle,
  @required BuildContext context,
  Color bgColor = defaultColor,
  Color textColor = Colors.white,
  bool barrierDismissible = true,
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  return Navigator.of(context, rootNavigator: true)
      .push<T>(CustomOverlayRoute<T>(
    barrierColor: Colors.transparent.withOpacity(0.01),
    builder: (context) {
      return InfomationDialog(
        bgColor: bgColor,
        x: x,
        y: y,
        title: title,
        subTitle: subTitle,
        textColor: textColor,
      );
    },
    theme: Theme.of(context, shadowThemeOnly: true),
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  ));
}

class InfomationDialog extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color bgColor;
  final Color textColor;

  final double x;
  final double y;

  const InfomationDialog(
      {Key key,
      this.x,
      this.y,
      this.title,
      this.subTitle,
      this.bgColor,
      this.textColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    bool top = height / 2 > y;
    bool left = width / 2 > x;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Positioned(
          top: top ? y + 15 : null,
          bottom: top ? null : height - y + 15,
          left: left ? min(max(x - 40, 0), width - 250) : null,
          right: left ? null : min(max(width - x - 40, 0), width - 250),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minWidth: 200, maxWidth: 250, minHeight: 130),
            child: Card(
              margin: EdgeInsets.all(0.0),
              elevation: 0.0,
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
                color: bgColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: FontHelper.bold(textColor, 14),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      subTitle,
                      style: FontHelper.medium(textColor, 12),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: top ? y : null,
          bottom: top ? null : height - y,
          left: left ? max(x - 15, 0) : null,
          right: left ? null : max(width - x - 15, 0),
          child: PhysicalShape(
            clipper: _TriangleClipper(inverted: top),
            color: bgColor,
            child: Container(
              height: 15,
              width: 30,
            ),
          ),
        )
      ],
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  final bool inverted;

  _TriangleClipper({this.inverted = false});
  @override
  Path getClip(Size size) {
    if (inverted) {
      final path = Path();
      path.moveTo(0.0,size.height);
      path.lineTo(size.width,size.height);
      path.lineTo(size.width / 2, 0.0);
      path.close();
      return path;
    } else {
      final path = Path();
      path.lineTo(size.width, 0.0);
      path.lineTo(size.width / 2, size.height);
      path.close();
      return path;
    }
  }

  @override
  bool shouldReclip(_TriangleClipper oldClipper) => false;
}
