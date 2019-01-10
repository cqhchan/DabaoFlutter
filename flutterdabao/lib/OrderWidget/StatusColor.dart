import 'package:flutter/material.dart';

class StatusColor extends StatelessWidget {
  final color;
  final borderRadius;

  const StatusColor({Key key, @required this.color, this.borderRadius})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 9,
      decoration: BoxDecoration(color: color, borderRadius: borderRadius),
    );
  }
}
