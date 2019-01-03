import 'package:flutter/material.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/ExtraProperties/Selectable.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/Model/Order.dart';

/// A configurable Expansion Tile edited from the flutter material implementation
/// that allows for customization of most of the behaviour. Includes providing colours,
/// replacement widgets on expansion, and  animating preceding/following widgets.
///
/// See:
/// [ExpansionTile]
class ConfigurableExpansionTile extends StatefulWidget {
  /// Creates a [Widget] with an optional [animatedWidgetPrecedingHeader] and/or
  /// [animatedWidgetFollowingHeader]. Optionally, the header can change on the
  /// expanded state by proving a [Widget] in [headerExpanded]. Colors can also
  /// be specified for the animated transitions/states. [children] are revealed
  /// when the expansion tile is expanded.
  const ConfigurableExpansionTile(
      {Key key,
      this.headerBackgroundColorStart = Colors.transparent,
      this.onExpansionChanged,
      this.children = const <Widget>[],
      this.initiallyExpanded = false,
      @required this.header,
      this.animatedWidgetFollowingHeader,
      this.animatedWidgetPrecedingHeader,
      this.expandedBackgroundColor,
      this.borderColorStart = Colors.transparent,
      this.borderColorEnd = Colors.transparent,
      this.topBorderOn = true,
      this.bottomBorderOn = true,
      this.kExpand = const Duration(milliseconds: 200),
      this.headerBackgroundColorEnd,
      this.headerExpanded,
      this.headerAnimationTween,
      this.borderAnimationTween,
      this.animatedWidgetTurnTween,
      this.animatedWidgetTween,
      @required this.selectable})
      : assert(initiallyExpanded != null),
        super(key: key);

  /// Called when the tile expands or collapses.
  ///
  /// When the tile starts expanding, this function is called with the value
  /// true. When the tile starts collapsing, this function is called with
  /// the value false.
  final ValueChanged<bool> onExpansionChanged;

  /// The widgets that are displayed when the tile expands.
  ///
  /// Typically [ListTile] widgets.
  final List<Widget> children;

  final Order selectable;

  /// The color of the header, useful to set if your animating widgets are
  /// larger than the header widget, or you want an animating color, in which
  /// case your header widget should be transparent
  final Color headerBackgroundColorStart;

  /// The [Color] the header will transition to on expand
  final Color headerBackgroundColorEnd;

  /// The [Color] of the background of the [children] when expanded
  final Color expandedBackgroundColor;

  /// Specifies if the list tile is initially expanded (true) or collapsed (false, the default).
  final bool initiallyExpanded;

  /// The header for the expansion tile
  final Widget header;

  /// An optional widget to replace [header] with if the list is expanded
  final Widget headerExpanded;

  /// A widget to rotate following the [header] (ie an arrow)
  final Widget animatedWidgetFollowingHeader;

  /// A widget to rotate preceding the [header] (ie an arrow)
  final Widget animatedWidgetPrecedingHeader;

  /// The duration of the animations
  final Duration kExpand;

  /// The color the border start, before the list is expanded
  final Color borderColorStart;

  /// The color of the border at the end of animation, after the list is expanded
  final Color borderColorEnd;

  /// Turns the top border of the list is on/off
  final bool topBorderOn;

  /// Turns the bottom border of the list on/off
  final bool bottomBorderOn;

  /// Header transition tween
  final Animatable<double> headerAnimationTween;

  /// Border animation tween
  final Animatable<double> borderAnimationTween;

  /// Tween for turning [animatedWidgetFollowingHeader] and [animatedWidgetPrecedingHeader]
  final Animatable<double> animatedWidgetTurnTween;

  ///  [animatedWidgetFollowingHeader] and [animatedWidgetPrecedingHeader] transition tween
  final Animatable<double> animatedWidgetTween;

  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);
  static final Animatable<double> _halfTween =
      Tween<double>(begin: 0.0, end: 0.5);

  static final Animatable<double> _easeOutTween =
      CurveTween(curve: Curves.easeOut);
  @override
  _ConfigurableExpansionTileState createState() =>
      _ConfigurableExpansionTileState();
}

class _ConfigurableExpansionTileState extends State<ConfigurableExpansionTile>
    with SingleTickerProviderStateMixin, HavingSubscriptionMixin {
  AnimationController _controller;
  Animation<double> _iconTurns;
  Animation<double> _heightFactor;

  Animation<Color> _borderColor;
  Animation<Color> _headerColor;

  final ColorTween _borderColorTween = ColorTween();
  final ColorTween _headerColorTween = ColorTween();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.kExpand, vsync: this);
    _heightFactor = _controller.drive(ConfigurableExpansionTile._easeInTween);
    _iconTurns = _controller.drive(
        (widget.animatedWidgetTurnTween ?? ConfigurableExpansionTile._halfTween)
            .chain(widget.animatedWidgetTween ??
                ConfigurableExpansionTile._easeInTween));

    _borderColor = _controller.drive(_borderColorTween.chain(
        widget.borderAnimationTween ??
            ConfigurableExpansionTile._easeOutTween));
    _borderColorTween.end = widget.borderColorEnd;

    _headerColor = _controller.drive(_headerColorTween.chain(
        widget.headerAnimationTween ?? ConfigurableExpansionTile._easeInTween));
    _headerColorTween.end =
        widget.headerBackgroundColorEnd ?? widget.headerBackgroundColorStart;

    if (widget.selectable.isSelectedProperty.value != widget.initiallyExpanded)
      widget.selectable.isSelectedProperty.value = widget.initiallyExpanded;

    if (widget.selectable.isSelected) _controller.value = 1.0;
    print("testing init " + widget.selectable.uid);

    subscription.add(widget.selectable.isSelectedProperty.producer.listen((selected){
      print("testing " + widget.selectable.uid);
      if (selected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      if (widget.onExpansionChanged != null)
        widget.onExpansionChanged(selected);
    }));
  }

  @override
  void dispose() {
    print("testing dispose "+ widget.selectable.uid);
    subscription.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      widget.selectable.toggle();

    });
  }

  Widget _buildChildren(BuildContext context, Widget child) {
    final Color borderSideColor = _borderColor.value ?? widget.borderColorStart;
    final Color headerColor =
        _headerColor?.value ?? widget.headerBackgroundColorStart;
    return Container(
        decoration: BoxDecoration(
            border: Border(
          top: BorderSide(
              color: widget.topBorderOn ? borderSideColor : Colors.transparent),
          bottom: BorderSide(
              color:
                  widget.bottomBorderOn ? borderSideColor : Colors.transparent),
        )),
        child: GestureDetector(
          onTap: () {
            _handleTap();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  color: headerColor,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // RotationTransition(
                      //   turns: _iconTurns,
                      //   child:
                      widget.animatedWidgetPrecedingHeader ?? Container(),
                      // ),
                      _getHeader(),
                      RotationTransition(
                        turns: _iconTurns,
                        child:
                            widget.animatedWidgetFollowingHeader ?? Container(),
                      )
                    ],
                  )),
              ClipRect(
                child: Align(
                  heightFactor: _heightFactor.value,
                  child: child,
                ),
              ),
            ],
          ),
        ));
  }

  /// Retrieves the header to display for the tile, derived from [_isExpanded] state
  Widget _getHeader() {
    if (!widget.selectable.isSelected) {
      return widget.header;
    } else {
      return widget.headerExpanded ?? widget.header;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool closed =
        !widget.selectable.isSelected && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: Container(
          color: widget.expandedBackgroundColor ?? Colors.transparent,
          child: Column(children: widget.children)),
    );
  }
}
