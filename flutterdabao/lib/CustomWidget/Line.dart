import 'package:flutter/widgets.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

class Line extends StatelessWidget {
  final EdgeInsetsGeometry margin;
  final Color color;

  Line({Key key, this.margin, this.color = ColorHelper.dabaoGreyE0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.0,
      color: color,
      margin: margin,
    );
  }
}
