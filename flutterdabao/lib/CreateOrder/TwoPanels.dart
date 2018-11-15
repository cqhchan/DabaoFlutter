import 'package:flutter/material.dart';

import 'package:flutterdabao/CreateOrder/TimeWidget.dart';
import 'package:flutterdabao/CreateOrder/DateWidget.dart';
// import 'package:flutterdabao/CreateOrder/BackDropMenu.dart';
// import 'package:flutterdabao/CreateOrder/FoodTypeWidget.dart';
import 'package:flutterdabao/CreateOrder/LeafletMap.dart';
import 'package:flutterdabao/CreateOrder/OrderMenu.dart';


class TwoPanels extends StatefulWidget {
  final AnimationController controller;

  TwoPanels({this.controller});

  @override
  _TwoPanelsState createState() => new _TwoPanelsState();
}

class _TwoPanelsState extends State<TwoPanels> {
  static const header_height = 32.0;

  Animation<RelativeRect> getPanelAnimation(BoxConstraints constraints) {
    final height = constraints.biggest.height;
    final backPanelHeight = height - header_height;
    final frontPanelHeight = -header_height;

    return new RelativeRectTween(
            begin: new RelativeRect.fromLTRB(
                0.0, backPanelHeight, 0.0, frontPanelHeight),
            end: new RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0))
        .animate(new CurvedAnimation(
            parent: widget.controller, curve: Curves.linear));
  }

  Widget bothPanels(BuildContext context, BoxConstraints constraints) {
    final ThemeData theme = Theme.of(context);

    return new Container(
      child: new Stack(
        children: <Widget>[
          new Container(
            color: theme.primaryColor,
            child: new Center(
              child: Stack(
                //Map Panel
                children: <Widget>[
                  //Map Widget
                  LeafletMap(),
                  //TimeSlot Widget
                  SafeArea(
                    // left: true,
                    // right: true,
                    top: true,
                    bottom: true,
                    child: Column(
                      children: <Widget>[
                        DatePicker(),
                        TimePicker(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          new PositionedTransition(
            rect: getPanelAnimation(constraints),
            child: new Material(
              elevation: 12.0,
              borderRadius: new BorderRadius.only(
                  topLeft: new Radius.circular(20.0),
                  topRight: new Radius.circular(20.0)),
              child: new Column(
                children: <Widget>[
                  //Menu Panel
                  new Container(
                    height: header_height,
                    child: new Center(
                      child: new Text(
                        "Order Menu",
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                  ),
                  //List Panel
                  new Expanded(
                    child: new Center(
                      child: Text("List"),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
      builder: bothPanels,
    );
  }
}
