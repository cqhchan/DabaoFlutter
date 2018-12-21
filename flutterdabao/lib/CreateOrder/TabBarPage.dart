import 'package:flutter/material.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';

class TabBarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: MaterialApp(
        theme: ThemeData(
            primaryColor: ColorHelper.dabaoOrange,
            accentColor: ColorHelper.dabaoOrange),
        home: Scaffold(
          appBar: AppBar(
            // backgroundColor: ColorHelper.dabaoOrange,
            leading: GestureDetector(
              child: Icon(
                Icons.home,
                color: Colors.black,
              ),
            ),
            title: Text(
              'DABAOER',
              style: FontHelper.header3TextStyle,
            ),
            bottom: TabBar( 
              indicatorColor: ColorHelper.dabaoGreyE0,
              indicatorWeight: 0.0,
              labelStyle: FontHelper.norma2TextStyle,
              indicator: BoxDecoration(color: ColorHelper.dabaoOffWhiteF5),
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
          body: TabBarView(
            children: [
              Icon(Icons.directions_car),
              Icon(Icons.directions_transit),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );
  }
}

