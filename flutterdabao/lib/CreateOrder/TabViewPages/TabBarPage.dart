import 'package:flutter/material.dart';
import 'package:flutterdabao/CreateOrder/TabViewPages/BrowseOrderTab.dart';
import 'package:flutterdabao/CreateOrder/TabViewPages/ConfirmedTab.dart';
import 'package:flutterdabao/CreateOrder/TabViewPages/MyRouteTab.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';

class TabBarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.home,
            color: Colors.black,
          ),
        ),
        elevation: 0.0,
        title: Text(
          'DABAOER',
          style: FontHelper.header3TextStyle,
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            Container(
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
                      text: 'Browse Orders',
                    ),
                    Tab(
                      text: 'Confirmed',
                    ),
                    Tab(
                      text: 'My Route',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  BrowseOrderTabView(),
                  ConfirmedTabView(),
                  MyRouteTabView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
