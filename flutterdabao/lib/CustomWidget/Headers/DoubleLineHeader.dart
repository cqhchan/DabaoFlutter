import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';

class DoubleLineHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final GestureDetector leftButton;
  final GestureDetector rightButton;
  final TextStyle headerTextStyle;
  final TextStyle subTitleTextStyle;
  final VoidCallback headerTapped;
  final VoidCallback closeTapped;

  final Color backgroundColor;
  final Color topLineColor;

  DoubleLineHeader({
    Key key,
    this.backgroundColor = Colors.white,
    this.title,
    this.headerTextStyle = FontHelper.overlayHeader,
    this.subTitleTextStyle = FontHelper.overlaySubtitleHeader,
    this.leftButton,
    this.rightButton,
    this.subtitle,
    this.topLineColor = ColorHelper.dabaoOrange,
    this.headerTapped,
    this.closeTapped,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DoubleLineHeaderState();
  }
}

class _DoubleLineHeaderState extends State<DoubleLineHeader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listOfWidget = List();

    if (widget.leftButton != null) listOfWidget.add(widget.leftButton);

    if (widget.title != null) {
      List<Widget> columList = List();

      if (widget.subtitle != null)
        columList.add(Container(
          child: Text(
            widget.subtitle,
            style: widget.subTitleTextStyle,
          ),
        ));

      columList.add(Flexible(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 200.0),
          child: Text(
            widget.title,
            overflow: TextOverflow.ellipsis,
            style: widget.headerTextStyle,
          ),
        ),
      ));

      listOfWidget.add(
        GestureDetector(
          onTap: widget.headerTapped,
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.only(left: 18.0, right: 18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columList,
            ),
          ),
        ),
      );
    }

    if (widget.rightButton != null)
      listOfWidget.add(
          Align(alignment: Alignment.centerRight, child: widget.rightButton));
    return Container(
        height: 80,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3.0),
                  color: ColorHelper.dabaoOffGreyD8,
                ),
                height: 6.0,
                width: 54.0,
                margin: EdgeInsets.only(bottom: 8),
              ),
            ),
            Container(
              height: 10,
              width: MediaQuery.of(context).size.width,
              color: widget.topLineColor,
            ),
            Expanded(
                child: Container(
              color: widget.backgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: listOfWidget,
              ),
            ))
          ],
        ));
  }
}
