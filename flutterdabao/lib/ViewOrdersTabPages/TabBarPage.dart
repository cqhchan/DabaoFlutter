import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterdabao/Chat/ChatNavigationButton.dart';

import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/LocationHelper.dart';
import 'package:flutterdabao/ViewOrdersTabPages/BrowseOrderTab.dart';
import 'package:flutterdabao/ViewOrdersTabPages/ConfirmedTab.dart';
import 'package:flutterdabao/ViewOrdersTabPages/MyRouteTab.dart';

class TabBarPage extends StatefulWidget {

  final int initialPage;

  const TabBarPage({Key key, this.initialPage = 2}) : super(key: key);

  @override
  TabBarPageState createState() {
    return new TabBarPageState();
  }
}

class TabBarPageState extends State<TabBarPage> with SingleTickerProviderStateMixin {


    TabController _tabController;

  void initState() {
    super.initState();
    // Request permission and start listening to current location
    startListeningToCurrentLocation();
        _tabController = new TabController(initialIndex: widget.initialPage, vsync: this, length:3);

  }

  @override
    void dispose() {
      _tabController.dispose();
      super.dispose();
    }

  //Ask for permission and start listening to current location
  void startListeningToCurrentLocation() async {
    ConfigHelper.instance.startListeningToCurrentLocation(
        LocationHelper.instance.hardAskForPermission(
            context,
            Text("Please Enable Location"),
            Text(
                "Dabao needs your location to verify your Orders/Deliveries")));
  }
  


  moveToTab(int tab){
    print("called move to ${tab}");
    _tabController.animateTo(tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: null,
        actions: <Widget>[
          ChatNavigationButton(
            bgColor: ColorHelper.dabaoOrange,
          ),
          GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(right: 20, left: 10),
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/icons/arrow_down.png",
                  ),
                ),
              ))
        ],
        elevation: 0.0,
        title: StreamBuilder<List>(
          stream: ConfigHelper
              .instance.currentUserDeliveringOrdersProperty.producer,
          builder: (BuildContext context, snapshot) {
            if (!snapshot.hasData || snapshot.data.length == 0)
              return Text(
                "Your Active Deliveries",
                style: FontHelper.semiBold(Colors.black, 16),
              );

            return Text(
              "Your Active Deliveries (${snapshot.data.length})",
              style: FontHelper.semiBold(Colors.black, 16),
            );
          },
        ),
      ),
      body:Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 2.0),
              decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black, blurRadius: 1.5)]),
              constraints: BoxConstraints(maxHeight: 45.0),
              child: Material(
                color: Colors.white,
                child: TabBar(
                  controller:_tabController,
                  labelStyle: FontHelper.normal2TextStyle,
                  labelColor: ColorHelper.dabaoOrange,
                  unselectedLabelColor: ColorHelper.dabaoOffGrey70,
                  tabs: [
                    Tab(
                      child: Text(
                        "Browse",
                        style: FontHelper.semiBold(null, 12.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Confirmed",
                        style: FontHelper.semiBold(null, 12.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Tab(
                      child: Text(
                        "My Routes",
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
                controller: _tabController,
                children: [
                  BrowseOrderTabView(moveToTab: moveToTab),
                  ConfirmedTabView(),
                  MyRouteTabView(moveToTab: moveToTab),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
