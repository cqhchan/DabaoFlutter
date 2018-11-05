import 'package:flutter/material.dart';

import '../screens/create_delivery.dart';

class Dabaoer extends StatelessWidget {
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'MY DELIVERY'),
    Tab(text: 'JOBS'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        //AppBar
        appBar: AppBar(
          title: new Text('DABAOER'),
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
                    MaterialPageRoute(builder: (context) => Delivery()),
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
