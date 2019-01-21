import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const Duration _kBottomSheetDuration = Duration(milliseconds: 200);
const double _kMinFlingVelocity = 700.0;
const double _kCloseProgressThreshold = 0.5;

Future<T> showHalfBottomSheet<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
}) {
  assert(context != null);
  assert(builder != null);
  assert(debugCheckHasMaterialLocalizations(context));
  return Navigator.push(context, _HalfHalfPopUpRoute<T>(
    builder: builder,
    theme: Theme.of(context, shadowThemeOnly: true),
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  ));
}



Future<T> showFullBottomSheet<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
}) {
  assert(context != null);
  assert(builder != null);
  assert(debugCheckHasMaterialLocalizations(context));
  return Navigator.push(context, _FullPopUpRoute<T>(
    builder: builder,
    theme: Theme.of(context, shadowThemeOnly: true),
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  ));
}


class _HalfHalfPopUpRoute<T> extends PopupRoute<T> {
  _HalfHalfPopUpRoute({
    this.builder,
    this.theme,
    this.barrierLabel,
    RouteSettings settings,
  }) : super(settings: settings);

  final WidgetBuilder builder;
  final ThemeData theme;

  @override
  Color get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => false;

  @override
  final String barrierLabel;


  @override
  Duration get transitionDuration => _kBottomSheetDuration;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

   @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    // By definition, the bottom sheet is aligned to the bottom of the page
    // and isn't exposed to the top padding of the MediaQuery.
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _HalfBottomSheet<T>(route: this),
    );
    if (theme != null)
      bottomSheet = Theme(data: theme, child: bottomSheet);
    return bottomSheet;
  }

}



class _HalfBottomSheet<T> extends StatefulWidget {
  const _HalfBottomSheet({ Key key, this.route }) : super(key: key);

  final _HalfHalfPopUpRoute<T> route;

  @override
  _HalfBottomSheetState<T> createState() => _HalfBottomSheetState<T>();
}

class _HalfBottomSheetState<T> extends State<_HalfBottomSheet<T>> {
  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    String routeLabel;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        routeLabel = '';
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        routeLabel = localizations.dialogLabel;
        break;
    }

    return GestureDetector(
      excludeFromSemantics: true,
      child: AnimatedBuilder(
        animation: widget.route.animation,
        builder: (BuildContext context, Widget child) {
          // Disable the initial animation when accessible navigation is on so
          // that the semantics are added to the tree at the correct time.
          final double animationValue = mediaQuery.accessibleNavigation ? 1.0 : widget.route.animation.value;
          return Semantics(
            scopesRoute: true,
            namesRoute: true,
            label: routeLabel,
            explicitChildNodes: true,
            child: ClipRect(
              child: CustomSingleChildLayout(
                delegate: _HalfBottomSheetLayout(animationValue),
                child: InvisibleBottomSheet(
                  animationController: widget.route._animationController,
                  onClosing: () => Navigator.pop(context),
                  builder: widget.route.builder,
                ),
              ),
            ),
          );
        }
      )
    );
  }
}

class _HalfBottomSheetLayout extends SingleChildLayoutDelegate {
  _HalfBottomSheetLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 15.0/16.0,
      //Set Max height 
      maxHeight: constraints.maxHeight * 15.0 / 16.0
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_HalfBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}




class _FullPopUpRoute<T> extends PopupRoute<T> {
  _FullPopUpRoute({
    this.builder,
    this.theme,
    this.barrierLabel,
    RouteSettings settings,
  }) : super(settings: settings);

  final WidgetBuilder builder;
  final ThemeData theme;

  @override
  Color get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => false;

  @override
  final String barrierLabel;


  @override
  Duration get transitionDuration => _kBottomSheetDuration;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

   @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    // By definition, the bottom sheet is aligned to the bottom of the page
    // and isn't exposed to the top padding of the MediaQuery.
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _FullBottomSheet<T>(route: this),
    );
    if (theme != null)
      bottomSheet = Theme(data: theme, child: bottomSheet);
    return bottomSheet;
  }

}



class _FullBottomSheet<T> extends StatefulWidget {
  const _FullBottomSheet({ Key key, this.route }) : super(key: key);

  final _FullPopUpRoute<T> route;

  @override
  _FullBottomSheetState<T> createState() => _FullBottomSheetState<T>();
}

class _FullBottomSheetState<T> extends State<_FullBottomSheet<T>> {
  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    String routeLabel;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        routeLabel = '';
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        routeLabel = localizations.dialogLabel;
        break;
    }

    return GestureDetector(
      excludeFromSemantics: true,
      child: AnimatedBuilder(
        animation: widget.route.animation,
        builder: (BuildContext context, Widget child) {
          // Disable the initial animation when accessible navigation is on so
          // that the semantics are added to the tree at the correct time.
          final double animationValue = mediaQuery.accessibleNavigation ? 1.0 : widget.route.animation.value;
          return Semantics(
            scopesRoute: true,
            namesRoute: true,
            label: routeLabel,
            explicitChildNodes: true,
            child: ClipRect(
              child: CustomSingleChildLayout(
                delegate: _FullBottomSheetLayout(animationValue),
                child: InvisibleBottomSheet(
                  animationController: widget.route._animationController,
                  onClosing: () => Navigator.pop(context),
                  builder: widget.route.builder,
                ),
              ),
            ),
          );
        }
      )
    );
  }
}

class _FullBottomSheetLayout extends SingleChildLayoutDelegate {
  _FullBottomSheetLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 15.0/16.0,
      //Set Max height 
      maxHeight: constraints.maxHeight * 16.0 / 16.0
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_FullBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

/// A material design bottom sheet.
///
/// There are two kinds of bottom sheets in material design:
///
///  * _Persistent_. A persistent bottom sheet shows information that
///    supplements the primary content of the app. A persistent bottom sheet
///    remains visible even when the user interacts with other parts of the app.
///    Persistent bottom sheets can be created and displayed with the
///    [ScaffoldState.showBottomSheet] function or by specifying the
///    [Scaffold.bottomSheet] constructor parameter.
///
///  * _Modal_. A modal bottom sheet is an alternative to a menu or a dialog and
///    prevents the user from interacting with the rest of the app. Modal bottom
///    sheets can be created and displayed with the [showModalBottomSheet]
///    function.
///
/// The [BottomSheet] widget itself is rarely used directly. Instead, prefer to
/// create a persistent bottom sheet with [ScaffoldState.showBottomSheet] or
/// [Scaffold.bottomSheet], and a modal bottom sheet with [showModalBottomSheet].
///
/// See also:
///
///  * [ScaffoldState.showBottomSheet]
///  * [showModalBottomSheet]
///  * <https://material.google.com/components/bottom-sheets.html>
class InvisibleBottomSheet extends StatefulWidget {
  /// Creates a bottom sheet.
  ///
  /// Typically, bottom sheets are created implicitly by
  /// [ScaffoldState.showBottomSheet], for persistent bottom sheets, or by
  /// [showModalBottomSheet], for modal bottom sheets.
  const InvisibleBottomSheet({
    Key key,
    this.animationController,
    this.enableDrag = true,
    this.elevation = 0.0,
    @required this.onClosing,
    @required this.builder
  }) : assert(enableDrag != null),
       assert(onClosing != null),
       assert(builder != null),
       assert(elevation != null),
       super(key: key);

  /// The animation that controls the bottom sheet's position.
  ///
  /// The BottomSheet widget will manipulate the position of this animation, it
  /// is not just a passive observer.
  final AnimationController animationController;

  /// Called when the bottom sheet begins to close.
  ///
  /// A bottom sheet might be prevented from closing (e.g., by user
  /// interaction) even after this callback is called. For this reason, this
  /// callback might be call multiple times for a given bottom sheet.
  final VoidCallback onClosing;

  /// A builder for the contents of the sheet.
  ///
  /// The bottom sheet will wrap the widget produced by this builder in a
  /// [Material] widget.
  final WidgetBuilder builder;

  /// If true, the bottom sheet can dragged up and down and dismissed by swiping
  /// downards.
  ///
  /// Default is true.
  final bool enableDrag;

  /// The z-coordinate at which to place this material. This controls the size
  /// of the shadow below the material.
  ///
  /// Defaults to 0.
  final double elevation;

  @override
  _InvisibleBottomSheetState createState() => _InvisibleBottomSheetState();

  /// Creates an animation controller suitable for controlling a [BottomSheet].
  static AnimationController createAnimationController(TickerProvider vsync) {
    return AnimationController(
      duration: _kBottomSheetDuration,
      debugLabel: 'BottomSheet',
      vsync: vsync,
    );
  }
}

class _InvisibleBottomSheetState extends State<InvisibleBottomSheet> {

  final GlobalKey _childKey = GlobalKey(debugLabel: 'BottomSheet child');

  double get _childHeight {
    final RenderBox renderBox = _childKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  bool get _dismissUnderway => widget.animationController.status == AnimationStatus.reverse;

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_dismissUnderway)
      return;
    widget.animationController.value -= details.primaryDelta / (_childHeight ?? details.primaryDelta);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dismissUnderway)
      return;
    if (details.velocity.pixelsPerSecond.dy > _kMinFlingVelocity) {
      final double flingVelocity = -details.velocity.pixelsPerSecond.dy / _childHeight;
      if (widget.animationController.value > 0.0)
        widget.animationController.fling(velocity: flingVelocity);
      if (flingVelocity < 0.0)
        widget.onClosing();
    } else if (widget.animationController.value < _kCloseProgressThreshold) {
      if (widget.animationController.value > 0.0)
        widget.animationController.fling(velocity: -1.0);
      widget.onClosing();
    } else {
      widget.animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget bottomSheet = Material(
      key: _childKey,
      color: Colors.transparent,
      elevation: widget.elevation,
      child: widget.builder(context),
    );
    return !widget.enableDrag ? bottomSheet : GestureDetector(
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      child: bottomSheet,
      excludeFromSemantics: true,
    );
  }
}
