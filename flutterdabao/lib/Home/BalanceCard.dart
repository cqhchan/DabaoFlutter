import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/CustomWidget/ScaleGestureDetector.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/Model/User.dart';

class BalanceCard extends StatelessWidget {
  final AsyncSnapshot<User> user;

  BalanceCard(this.user);

  @override
  Widget build(BuildContext context) {

    return Container(
        padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        width: MediaQuery.of(context).size.width,
        height: 170.0,
        child: Card(
          elevation: 4.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: user.hasData
              ? Column(
                  children: <Widget>[
                    topWidget(),
                    Line(
                      margin: EdgeInsets.fromLTRB(25, 0, 35, 0),
                    ),
                    bottomRow(),
                  ],
                )
              : Center(
                  child: new CircularProgressIndicator(
                  value: null,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ColorHelper.dabaoOrange),
                  strokeWidth: 7.0,
                )),
        ));
  }

  Row bottomRow() {
    return Row(
      children: <Widget>[earnedBox(), savedBox()],
    );
  }

  Expanded savedBox() {
    return Expanded(
        // How much saved
        child: Container(
      child: StreamBuilder(
        stream: user.data.amountSaved,
        builder: (BuildContext context, snapshot) => snapshot.hasData
            ? Center(
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Text(
                          "I have Saved",
                          style: FontHelper.semiBold14Black,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Text(
                            "\$" + snapshot.data.toString(),
                            style: FontHelper.semiBold20Orange,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: new CircularProgressIndicator(
                value: null,
                valueColor:
                    AlwaysStoppedAnimation<Color>(ColorHelper.dabaoOrange),
                strokeWidth: 3.0,
              )),
      ),
      margin: EdgeInsets.fromLTRB(12, 12.5, 25, 12.5),
      height: 85,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 1),
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 0.1,
                blurRadius: 2.0)
          ],
          borderRadius: BorderRadius.all(Radius.circular(18.0))),
    ));
  }

  Expanded earnedBox() {
    return Expanded(
        // How much Earned
        child: Container(
      child: StreamBuilder(
        stream: user.data.amountEarned,
        builder: (BuildContext context, snapshot) => snapshot.hasData
            ? Center(
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Text(
                          "I have Earned",
                          style: FontHelper.semiBold14Black,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Text(
                            "\$" + snapshot.data.toString(),
                            style: FontHelper.semiBold20Orange,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: new CircularProgressIndicator(
                value: null,
                valueColor:
                    AlwaysStoppedAnimation<Color>(ColorHelper.dabaoOrange),
                strokeWidth: 3.0,
              )),
      ),
      height: 85,
      margin: EdgeInsets.fromLTRB(25, 12.5, 12, 12.5),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 1),
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 0.1,
                blurRadius: 2.0)
          ],
          borderRadius: BorderRadius.all(Radius.circular(18.0))),
    ));
  }

  Expanded topWidget() {
    return Expanded(
        child: Container(
      margin: EdgeInsets.fromLTRB(25, 0, 35, 0),
      child: Center(
          child: Row(
        children: <Widget>[
          Text(
            "Dabao Balance",
            style: FontHelper.semiBold16Black,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "\$4.00",
                style: FontHelper.semiBold16Black,
              ),
            ),
          )
        ],
      )),
    ));
  }
}
