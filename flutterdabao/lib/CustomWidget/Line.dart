import 'package:flutter/widgets.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

class Line extends StatelessWidget {
  final EdgeInsetsGeometry margin;
  final Color color;
  final bool vertical;

  Line({Key key, this.margin, this.color = ColorHelper.dabaoGreyE0, this.vertical = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if (vertical) {
      return Container(
      width: 1.0,
      color: color,
      margin: margin,
    );
    }
    else {
    return Container(
      height: 1.0,
      color: color,
      margin: margin,
    );
  }
  }
}
