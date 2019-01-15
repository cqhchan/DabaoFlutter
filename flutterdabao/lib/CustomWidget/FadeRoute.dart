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

class SlideUpRoute<T> extends PageRouteBuilder {
  final Widget widget;
  SlideUpRoute({this.widget})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return widget;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return SlideTransition(
              position: new Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: new SlideTransition(
                position: new Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(0.0, 1.0),
                ).animate(secondaryAnimation),
                child: child,
              ),
            );
          },
        );
}
