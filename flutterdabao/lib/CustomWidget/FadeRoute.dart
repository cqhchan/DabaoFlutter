import 'package:flutter/material.dart';

class FadeRoute extends PageRouteBuilder {
  final Widget widget;
  FadeRoute({this.widget})
      : super(pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return widget;
        }, transitionsBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child) {
          return new FadeTransition(
            alwaysIncludeSemantics: true,
            opacity: animation,
            // position: new Tween<Offset>(
            //   begin: const Offset(0.5 , 0.0),
            //   end: Offset.zero,
            // ).animate(animation),
            child: child,
          );
        });
}
