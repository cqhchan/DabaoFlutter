import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'dart:ui';
import 'package:path_drawing/path_drawing.dart';

class DottenLineDecoration extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback onChanged]) {
    return new _DottenLineDecorationPainter();
  }
}


class _DottenLineDecorationPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = new Paint()
      ..strokeWidth = 1.0
      ..color = ColorHelper.dabaoOffGreyD3
      ..style = PaintingStyle.stroke;
    final path = Path();

    final rect = offset & configuration.size;
    path.moveTo(rect.left, rect.top + rect.height / 2);
    path.lineTo(rect.right, rect.top + rect.height / 2);
    Path dottenPath = dashPath(path, dashArray: CircularIntervalList([7, 7]));
    canvas.drawPath(dottenPath, paint);
    canvas.restore();
  }
}
