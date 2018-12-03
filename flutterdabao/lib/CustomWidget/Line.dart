import 'package:flutter/widgets.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';

class Line extends StatelessWidget {

  final EdgeInsetsGeometry margin;

  Line({
    Key key,
    this.margin
  }):super(key:key);

  

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 1.0,
      color: ColorHelper.dabaoGreyE0,
      margin: margin,
    );
  }
}
