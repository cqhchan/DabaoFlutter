import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';


class ScaleGestureDetector extends StatefulWidget {

  ScaleGestureDetector(
      {Key key,
      this.child,
      this.onTapDown,
      this.onTapUp,
      this.onTap,
      this.onTapCancel,
      this.onDoubleTap,
      this.onLongPress,
      this.onLongPressUp,
      this.onVerticalDragDown,
      this.onVerticalDragStart,
      this.onVerticalDragUpdate,
      this.onVerticalDragEnd,
      this.onVerticalDragCancel,
      this.onHorizontalDragDown,
      this.onHorizontalDragStart,
      this.onHorizontalDragUpdate,
      this.onHorizontalDragEnd,
      this.onHorizontalDragCancel,
      this.onPanDown,
      this.onPanStart,
      this.onPanUpdate,
      this.onPanEnd,
      this.onPanCancel,
      this.onScaleStart,
      this.onScaleUpdate,
      this.onScaleEnd,
      this.behavior,
      this.animationDuration = 0,
      this.maxScale = 1.0,
      this.minScale = 0.95,
      this.excludeFromSemantics = false})
      : super(
          key: key,
        );


  // scale size when depressed
  final double minScale;

  // scale size when undepressed
  final double maxScale;

  // duration of animation in milliseconds
  final int animationDuration;


  final Widget child;

  /// A pointer that might cause a tap has contacted the screen at a particular
  /// location.
  ///
  /// This is called after a short timeout, even if the winning gesture has not
  /// yet been selected. If the tap gesture wins, [onTapUp] will be called,
  /// otherwise [onTapCancel] will be called.
  final GestureTapDownCallback onTapDown;

  /// A pointer that will trigger a tap has stopped contacting the screen at a
  /// particular location.
  ///
  /// This triggers immediately before [onTap] in the case of the tap gesture
  /// winning. If the tap gesture did not win, [onTapCancel] is called instead.
  final GestureTapUpCallback onTapUp;

  /// A tap has occurred.
  ///
  /// This triggers when the tap gesture wins. If the tap gesture did not win,
  /// [onTapCancel] is called instead.
  ///
  /// See also:
  ///
  ///  * [onTapUp], which is called at the same time but includes details
  ///    regarding the pointer position.
  final GestureTapCallback onTap;

  /// The pointer that previously triggered [onTapDown] will not end up causing
  /// a tap.
  ///
  /// This is called after [onTapDown], and instead of [onTapUp] and [onTap], if
  /// the tap gesture did not win.
  final GestureTapCancelCallback onTapCancel;

  /// The user has tapped the screen at the same location twice in quick
  /// succession.
  final GestureTapCallback onDoubleTap;

  /// A pointer has remained in contact with the screen at the same location for
  /// a long period of time.
  final GestureLongPressCallback onLongPress;

  /// A pointer that has triggered a long-press has stopped contacting the screen.
  final GestureLongPressUpCallback onLongPressUp;

  /// A pointer has contacted the screen and might begin to move vertically.
  final GestureDragDownCallback onVerticalDragDown;

  /// A pointer has contacted the screen and has begun to move vertically.
  final GestureDragStartCallback onVerticalDragStart;

  /// A pointer that is in contact with the screen and moving vertically has
  /// moved in the vertical direction.
  final GestureDragUpdateCallback onVerticalDragUpdate;

  /// A pointer that was previously in contact with the screen and moving
  /// vertically is no longer in contact with the screen and was moving at a
  /// specific velocity when it stopped contacting the screen.
  final GestureDragEndCallback onVerticalDragEnd;

  /// The pointer that previously triggered [onVerticalDragDown] did not
  /// complete.
  final GestureDragCancelCallback onVerticalDragCancel;

  /// A pointer has contacted the screen and might begin to move horizontally.
  final GestureDragDownCallback onHorizontalDragDown;

  /// A pointer has contacted the screen and has begun to move horizontally.
  final GestureDragStartCallback onHorizontalDragStart;

  /// A pointer that is in contact with the screen and moving horizontally has
  /// moved in the horizontal direction.
  final GestureDragUpdateCallback onHorizontalDragUpdate;

  /// A pointer that was previously in contact with the screen and moving
  /// horizontally is no longer in contact with the screen and was moving at a
  /// specific velocity when it stopped contacting the screen.
  final GestureDragEndCallback onHorizontalDragEnd;

  /// The pointer that previously triggered [onHorizontalDragDown] did not
  /// complete.
  final GestureDragCancelCallback onHorizontalDragCancel;

  /// A pointer has contacted the screen and might begin to move.
  final GestureDragDownCallback onPanDown;

  /// A pointer has contacted the screen and has begun to move.
  final GestureDragStartCallback onPanStart;

  /// A pointer that is in contact with the screen and moving has moved again.
  final GestureDragUpdateCallback onPanUpdate;

  /// A pointer that was previously in contact with the screen and moving
  /// is no longer in contact with the screen and was moving at a specific
  /// velocity when it stopped contacting the screen.
  final GestureDragEndCallback onPanEnd;

  /// The pointer that previously triggered [onPanDown] did not complete.
  final GestureDragCancelCallback onPanCancel;

  /// The pointers in contact with the screen have established a focal point and
  /// initial scale of 1.0.
  final GestureScaleStartCallback onScaleStart;

  /// The pointers in contact with the screen have indicated a new focal point
  /// and/or scale.
  final GestureScaleUpdateCallback onScaleUpdate;

  /// The pointers are no longer in contact with the screen.
  final GestureScaleEndCallback onScaleEnd;

  /// How this gesture detector should behave during hit testing.
  ///
  /// This defaults to [HitTestBehavior.deferToChild] if [child] is not null and
  /// [HitTestBehavior.translucent] if child is null.
  final HitTestBehavior behavior;

  /// Whether to exclude these gestures from the semantics tree. For
  /// example, the long-press gesture for showing a tooltip is
  /// excluded because the tooltip itself is included in the semantics
  /// tree directly and so having a gesture to show it would result in
  /// duplication of information.
  final bool excludeFromSemantics;


  @override
  State<StatefulWidget> createState() {
    return ScaleGestureDetectorState();
  }
}

class ScaleGestureDetectorState extends State<ScaleGestureDetector> with SingleTickerProviderStateMixin{
 
  Animation<double> animation;
  AnimationController _controller;
  ScaleTransition transition;
 

    
    // _controller = AnimationController(vsync: this);

  Future<Null> _playAnimation() async {
    try {
      await _controller.forward().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

Future<Null> _reverseAnimation() async {
  try {
      await _controller.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

@override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animationDuration),
    );
    animation = Tween(begin: widget.maxScale, end: widget.minScale).animate(_controller);
    super.initState();

  }

  @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

 @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widget.key,
      child:  ScaleTransition(scale: animation,child: widget.child ),

      onTapDown: (tapDownDetails) {
        _playAnimation();
        print("testing on tap down");


        if (widget.onDoubleTap != null)
        widget.onTapDown(tapDownDetails);

      },
      onTapUp: (tapUpDetails) {
        _reverseAnimation();
        if (widget.onDoubleTap != null)
        widget.onTapUp(tapUpDetails);

      },
      onTap: widget.onTap,
      onTapCancel: () {
        _reverseAnimation();
        if (widget.onDoubleTap != null)
        widget.onTapCancel();

      },
      onDoubleTap: widget.onDoubleTap,
      onLongPress: widget.onLongPress,
      onLongPressUp: widget.onLongPressUp,
      onVerticalDragDown: widget.onVerticalDragDown,
      onVerticalDragStart: widget.onVerticalDragStart,
      onVerticalDragUpdate: widget.onVerticalDragUpdate,
      onVerticalDragEnd: widget.onVerticalDragEnd,
      onVerticalDragCancel: widget.onVerticalDragCancel,
      onHorizontalDragDown: widget.onHorizontalDragDown,
      onHorizontalDragStart: widget.onHorizontalDragStart,
      onHorizontalDragUpdate: widget.onHorizontalDragUpdate,
      onHorizontalDragEnd: widget.onHorizontalDragEnd,
      onHorizontalDragCancel: widget.onHorizontalDragCancel,
      onPanDown: widget.onPanDown,
      onPanStart: widget.onPanStart,
      onPanUpdate: widget.onPanUpdate,
      onPanEnd: widget.onPanEnd,
      onPanCancel: widget.onPanCancel,
      onScaleStart: widget.onScaleStart,
      onScaleUpdate: widget.onScaleUpdate,
      onScaleEnd: widget.onScaleEnd,
      behavior: widget.behavior,
    );
  }


}
