import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:rxdart/rxdart.dart';

class ConfirmationProofPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ConfirmationProofPageState();
  }
}

class ConfirmationProofPageState extends State<ConfirmationProofPage>
    with SingleTickerProviderStateMixin {
  Observable secondTicker = Observable.timer("hi", Duration(minutes: 2));
  AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = new AnimationController(
        upperBound: 1.0,
        lowerBound: -1.0,
        duration: new Duration(seconds: 2),
        vsync: this)
      ..addListener(() {
        this.setState(() {});
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Color.fromRGBO(0xEB, 0xEB, 0xE8, 1.0),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color.fromRGBO(0xEB, 0xEB, 0xE8, 1.0),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(child: Image.asset("assets/images/InAppIcon.png")),
          Container(
            margin: EdgeInsets.only(bottom: 20, top: 10),
            child: Text(
              "*show this to stall merchants to get your discount!",
              style: FontHelper.regular(ColorHelper.dabaoOffBlack9B, 12.0),
            ),
          ),
        
          StreamBuilder(
            stream: secondTicker,
            builder: (context, snap) {
              DateTime currentTime =DateTime.now();
              return Column(
                children: <Widget>[
                    Text(DateTimeHelper.confirmationProofDate(currentTime),
              style: FontHelper.semiBold(Colors.black, 34)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(DateTimeHelper.hourAndMinSecond12Hour(currentTime),
                          style: FontHelper.regular(Colors.black, 50)),
                      Container(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(formatDate(currentTime, [am]),
                            style: FontHelper.regular(Colors.black, 25)),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: Container(
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned(
                      left:
                          MediaQuery.of(context).size.width * _controller.value,
                      width: MediaQuery.of(context).size.width * 0.8,
                      // alignment: Alignment(_controller.value, 0.0),
                      // widthFactor: 0.8,
                      child: Image.asset("assets/images/8Tdj.gif")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
