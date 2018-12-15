import 'package:flutter/material.dart';

const Duration transitionDuration = Duration(milliseconds: 200);

class CustomOverlayRoute<T> extends PopupRoute<T> {
  
  
  CustomOverlayRoute({
    this.barrierColor = Colors.black54,
    @required this.builder,
    this.theme,
    this.barrierLabel,
    this.barrierDismissible = false,
    RouteSettings settings,
  }) : super(settings: settings);

  final WidgetBuilder builder;
  final ThemeData theme;

  @override
  final Color barrierColor;

  @override
  final bool barrierDismissible;

  @override
  final String barrierLabel;


  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }


  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    // TODO: implement buildPage
    return builder(context);
  }

  @override
  // TODO: implement transitionDuration
  Duration get transitionDuration => transitionDuration;
}
