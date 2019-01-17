import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/Balance/Transaction.dart';
import 'package:flutterdabao/Balance/Withdrawal.dart';
import 'package:flutterdabao/CustomWidget/FadeRoute.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/CustomWidget/ScaleGestureDetector.dart';
import 'package:flutterdabao/Firebase/FirebaseCloudFunctions.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/User.dart';
import 'package:flutterdabao/Rewards/RewardsTab.dart';
import 'package:rxdart/rxdart.dart';

class BalanceCard extends StatelessWidget {
  final AsyncSnapshot<User> user;
  final BuildContext context;
  BalanceCard(this.user, this.context);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: user.hasData
          ? Column(
              children: <Widget>[
                topWidget(),
                Line(
                  color: ColorHelper.dabaoOrange,
                  margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
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
    );
  }

  Widget bottomRow() {
    return Container(
      child: Row(
        children: <Widget>[withdrawalBox(), voucherBox(), rewardsBox()],
      ),
    );
  }

  Expanded rewardsBox() {
    return Expanded(
        // How much Earned
        child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          FadeRoute(
              widget: RewardsTabBarPage(
            initalIndex: 1,
          )),
        );
      },
      child: Container(
        color: Colors.transparent,
        height: 85.0,
        margin: EdgeInsets.fromLTRB(0.0, 5, 10.0, 12.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                height: 40, child: Image.asset("assets/icons/reward_gift.png")),
            Text("DabaoRewards", style: FontHelper.regular12Black)
          ],
        ),
      ),
    ));
  }

  Expanded withdrawalBox() {
    return Expanded(
        // How much Earned
        child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SelectAccountPage()),
        );
      },
      child: Container(
        color: Colors.transparent,
        height: 85.0,
        margin: EdgeInsets.fromLTRB(10.0, 5, 0.0, 12.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                height: 40, child: Image.asset("assets/icons/cash_out.png")),
            Text("Cash Out", style: FontHelper.regular12Black)
          ],
        ),
      ),
    ));
  }

  Expanded voucherBox() {
    return Expanded(
        // How much Earned
        child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          FadeRoute(
              widget: RewardsTabBarPage(
            initalIndex: 0,
          )),
        );
      },
      child: Container(
        color: Colors.transparent,
        height: 85.0,
        margin: EdgeInsets.fromLTRB(0.0, 5, 0.0, 12.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                height: 40,
                child: Image.asset("assets/icons/MyVouchersIcon.png")),
            Text("Your Vouchers", style: FontHelper.regular12Black)
          ],
        ),
      ),
    ));
  }

  Widget topWidget() {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return TransactionsPage();
            }),
          );
        },
        child: Container(
          color: Colors.transparent,
          margin: EdgeInsets.fromLTRB(15.0, 15.0, 10.0, 10.0),
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
                  child: StreamBuilder<double>(
                      stream: ConfigHelper
                          .instance.currentUserWalletProperty.producer
                          .switchMap((wallet) => wallet == null
                              ? null
                              : Observable.combineLatest2<double, double,
                                      double>(
                                  (wallet.currentValue), (wallet.inWithdrawal),
                                  (currentValue, inWithdrawalValue) {
                                  if (currentValue != null &&
                                      inWithdrawalValue != null) {
                                    return currentValue - inWithdrawalValue;
                                  }
                                  return 0.0;
                                })),
                      builder: (context, snap) {
                        if (!snap.hasData)
                          return Text(
                            "\$0.00",
                            style: FontHelper.semiBold16Black,
                          );

                        return Text(
                          StringHelper.doubleToPriceString(snap.data),
                          style: FontHelper.semiBold16Black,
                        );
                      }),
                ),
              ),
              Container(
                  padding: EdgeInsets.only(right: 5.0, left: 5.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: ColorHelper.dabaoOffGrey70,
                  )),
            ],
          )),
        ));
  }
}
