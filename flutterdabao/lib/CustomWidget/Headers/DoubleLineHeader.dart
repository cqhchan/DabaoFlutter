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

  final Color backgroundColor;
  final Color topLineColor;

  DoubleLineHeader(
      {Key key,
      this.backgroundColor = Colors.white,
      this.title,
      this.headerTextStyle = FontHelper.overlayHeader,
      this.subTitleTextStyle = FontHelper.overlaySubtitleHeader,
      this.leftButton,
      this.rightButton,
      this.subtitle,
      this.topLineColor = ColorHelper.dabaoOrange})
      : super(key: key);

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

    if (widget.title != null)
      listOfWidget.add(Container(
        padding: EdgeInsets.only(left: 10.0),
        child: Text(
          widget.title,
          style: widget.headerTextStyle,
        ),
      ));

    if (widget.subtitle != null)
      listOfWidget.add(Container(
        padding: EdgeInsets.only(left: 5.0,top: 2.0),
        child: Text(
          widget.subtitle,
          style: widget.subTitleTextStyle,
        ),
      ));

    if (widget.rightButton != null)
      listOfWidget.add(
          Align(alignment: Alignment.centerRight, child: widget.rightButton));

    return Container(
        height: 120,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                child: Container(
                  color: Colors.transparent,
                  height: 54.0,
                  width: 54.0,
                  padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 18.0),
                  child: Image.asset('assets/icons/circle_close_icon.png'),
                ),
                onTap: () => Navigator.of(context).pop(),
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
        )
      
        );
  }
}
