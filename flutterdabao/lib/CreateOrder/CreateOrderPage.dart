import 'package:flutter/material.dart';

import 'package:flutterdabao/CreateOrder/DatetimeWidget.dart';
import 'package:flutterdabao/CreateOrder/FoodTypeWidget.dart';

class Order extends StatelessWidget {
  @override
  Widget build(BuildContext context) => new Scaffold(
        //App Bar
        appBar: new AppBar(
          title: new Text(
            'Create Orders',
            style: new TextStyle(
              fontSize: Theme.of(context).platform == TargetPlatform.iOS
                  ? 17.0
                  : 20.0,
            ),
          ),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),

        //Content of tabs
        body: new PageView(
          children: <Widget>[
            new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                DateTimePicker(),
                FoodType(),
              ],
            ),
          ],
        ),
      );
}
