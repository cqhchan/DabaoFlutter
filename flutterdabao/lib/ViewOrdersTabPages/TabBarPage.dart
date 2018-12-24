import 'package:flutter/material.dart';

import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/ViewOrdersTabPages/BrowseOrderTab.dart';
import 'package:flutterdabao/ViewOrdersTabPages/ConfirmedTab.dart';
import 'package:flutterdabao/ViewOrdersTabPages/MyRouteTab.dart';

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
        initialIndex: 2,
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
                      child:Text("Browse Orders", style: FontHelper.semiBold(null, 12.0),),
                    ),
                    Tab(
                      child:Text("Confirmed", style: FontHelper.semiBold(null, 12.0),),
                    ),
                    Tab(
                      child:Text("My Routes", style: FontHelper.semiBold(null, 12.0),),
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
