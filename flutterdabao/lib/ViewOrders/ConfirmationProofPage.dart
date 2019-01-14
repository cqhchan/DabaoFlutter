import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';

class ConfirmationProofPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ConfirmationProofPageState();
  }
}

class ConfirmationProofPageState extends State<ConfirmationProofPage> {
  DateTime currentTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Color.fromRGBO(0xEB, 0xEB, 0xE8, 1.0),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor:  Color.fromRGBO(0xEB, 0xEB, 0xE8, 1.0),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Image.asset("assets/images/InAppIcon.png")),
          Container(
            margin: EdgeInsets.only(bottom: 20,top: 10),
            child: Text(
              "*show this to stall merchants to get your discount!",
              style: FontHelper.regular(ColorHelper.dabaoOffBlack9B, 12.0),
            ),
          ),
          Text(DateTimeHelper.convertDateTimeToDate(currentTime),
              style: FontHelper.semiBold(Colors.black, 34)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(DateTimeHelper.hourAndMin12Hour(currentTime),
                  style: FontHelper.regular(Colors.black, 74)),
              Container(
                padding: EdgeInsets.only(bottom: 13),
                child: Text(formatDate(currentTime, [am]),
                    style: FontHelper.regular(Colors.black, 25)),
              ),
            ],
          ),
          Expanded(child: Image.asset("assets/images/8Tdj.gif"))
        ],
      ),
    );
  }
}
