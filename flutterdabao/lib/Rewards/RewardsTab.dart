import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterdabao/CreateOrder/OrderNow.dart';

import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:flutterdabao/Model/Voucher.dart';
import 'package:flutterdabao/Rewards/BrowseRewardPage.dart';
import 'package:flutterdabao/Rewards/MyVoucherPage.dart';
import 'package:flutterdabao/Rewards/SearchPromoCodePage.dart';

class RewardsTabBarPage extends StatefulWidget {
  final int initalIndex;

  RewardsTabBarPage({Key key, this.initalIndex = 2}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RewardsTabBarPageState();
  }
}

class RewardsTabBarPageState extends State<RewardsTabBarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorHelper.dabaoOffWhiteF5,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            size: 26,
            color: Colors.black,
          ),
        ),
        elevation: 0.0,
        title: Text(
          'DabaoRewards',
          style: FontHelper.header3TextStyle,
        ),
      ),
      body: DefaultTabController(
        length: 2,
        initialIndex: widget.initalIndex,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 2.0),
              decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black, blurRadius: 1.5)]),
              constraints: BoxConstraints(maxHeight: 45.0),
              child: Material(
                color: Colors.white,
                child: TabBar(
                  labelStyle: FontHelper.normal2TextStyle,
                  labelColor: ColorHelper.dabaoOrange,
                  unselectedLabelColor: ColorHelper.dabaoOffGrey70,
                  tabs: [
                    Tab(
                      child: Text(
                        "My Vouchers",
                        style: FontHelper.semiBold(null, 12.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Tab(
                      child: Text(
                        "My Rewards",
                        style: FontHelper.semiBold(null, 12.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  MyVoucherPage(
                    onCompletionCallback: (Voucher voucher) {
                      Navigator.popUntil(context,
                          ModalRoute.withName(Navigator.defaultRouteName));
                      OrderHolder holder = OrderHolder(voucher: voucher);
                      Navigator.of(context).push(MaterialPageRoute(
                          maintainState: !Platform.isIOS,
                          builder: (context) => OrderNow(
                                holder: holder,
                              )));
                    },
                  ),
                  BrowseRewardPage()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
