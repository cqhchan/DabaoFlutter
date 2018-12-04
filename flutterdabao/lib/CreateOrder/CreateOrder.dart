import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Tracker.dart';
import 'package:flutterdabao/CustomWidget/BackButton.dart';
import 'package:flutterdabao/CustomWidget/Map.dart';

class CreateOrder extends StatefulWidget {
  @override
  State createState() => CreateOrderState();
}

class CreateOrderState extends State<CreateOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              CustomizedMap(),
            ],
          ),
          CustomizedBackButton(),
          Tracker(),
        ],
      ),
    );
  }
}
