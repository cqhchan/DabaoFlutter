import 'package:flutter/material.dart';

import 'package:flutterdabao/CreateOrder/DatetimeWidget.dart';
import 'package:flutterdabao/CreateOrder/FoodTypeWidget.dart';
import 'package:flutterdabao/CreateOrder/LeafletMap.dart';

class Order extends StatelessWidget {
  @override
  Widget build(BuildContext context) => new Scaffold(
        //Content of tabs
        body: Stack(
          children: <Widget>[
            LeafletMap(),
            SafeArea(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20.0),
                    child: DateTimePicker(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// new ListView(
//           children: <Widget>[
//             new Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: <Widget>[
//                 DateTimePicker(),
//                 FoodType(),
//                 LeafletMap(),
//               ],
//             ),
//           ],
//         ),

// appBar: new AppBar(
//           title: new Text(
//             'Create Orders',
//             style: new TextStyle(
//               fontSize: Theme.of(context).platform == TargetPlatform.iOS
//                   ? 17.0
//                   : 20.0,
//             ),
//           ),
//           elevation:
//               Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
//         ),
