import 'package:flutter/material.dart';

import 'package:flutterdabao/screens/create_order.dart';

class Dabaoee extends StatelessWidget {
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'MY ORDERS'),
    Tab(text: 'MENU'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        //AppBar
        appBar: AppBar(
          title: new Text('DABAOEE'),
          bottom: TabBar(
            tabs: myTabs,
          ),
        ),

        //Tabs' Contents
        body: TabBarView(
          children: [
            //My Order Tabview
            Scaffold(
              floatingActionButton: new FloatingActionButton(
                elevation: 5.0,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Order()),
                  );
                },
                child: new Icon(Icons.add),
              ),
              body: Center(
                child: Image.asset(
                  'assets/CandyMonsterEdited.png',
                  scale: 1.5,
                ),
              ),
            ),

            //Browse Delivery Tabview
            Scaffold(
              body: Center(
                child: Image.asset(
                  'assets/CandyMonsterEdited.png',
                  scale: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
