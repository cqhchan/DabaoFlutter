import 'package:flutter/material.dart';

import 'package:flutterdabao/CustomWidget/OrderNow.dart';
import 'package:flutterdabao/CustomWidget/BackButton.dart';
import 'package:flutterdabao/CustomWidget/Map.dart';

class CreateOrder extends StatefulWidget {
  @override
  State createState() => CreateOrderState();
}

class CreateOrderState extends State<CreateOrder> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  VoidCallback _showPersBottomSheetCallBack;

  @override
  void initState() {
    super.initState();
    _showPersBottomSheetCallBack = _showBottomSheet;
  }

  void _showBottomSheet() {
    setState(() {
      _showPersBottomSheetCallBack = null;
    });

    _scaffoldKey.currentState
        .showBottomSheet((context) {
          return new Container(
            height: 300.0,
            color: Colors.greenAccent,
            child: new Center(
              child: new Text("Hi BottomSheet"),
            ),
          );
        })
        .closed
        .whenComplete(() {
          if (mounted) {
            setState(() {
              _showPersBottomSheetCallBack = _showBottomSheet;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              CustomizedMap(),
            ],
          ),
          CustomizedBackButton(),
          // OrderNow(),
        ],
      ),
    );
  }
}
