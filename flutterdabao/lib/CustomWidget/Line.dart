import 'package:flutter/widgets.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

class Line extends StatelessWidget {
  final EdgeInsetsGeometry margin;
  final Color color;
  final bool vertical;
  final double size;

  Line({Key key, this.margin, this.color = ColorHelper.dabaoGreyE0, this.vertical = false, this.size = 1.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if (vertical) {
      return Container(
      width: size,
      color: color,
      margin: margin,
    );
    }
    else {
    return Container(
      height: size,
      color: color,
      margin: margin,
    );
  }
  }
}
