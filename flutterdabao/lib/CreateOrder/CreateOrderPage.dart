import 'package:flutter/material.dart';

import 'package:flutterdabao/CreateOrder/TimeWidget.dart';
import 'package:flutterdabao/CreateOrder/DateWidget.dart';
import 'package:flutterdabao/CreateOrder/BackDrop.dart';
// import 'package:flutterdabao/CreateOrder/FoodTypeWidget.dart';
import 'package:flutterdabao/CreateOrder/LeafletMap.dart';


//Not in use
class Order extends StatelessWidget {
  @override
  Widget build(BuildContext context) => new Scaffold(
        //AppBar
        appBar: AppBar(
          title: new Text('CREATE ORDER'),
        ),
        body: Stack(
          children: <Widget>[
            //Map Widget
            LeafletMap(),
            //TimeSlot Widget
            SafeArea(
              // left: true,
              // right: true,
              top: true,
              bottom: true,
              child: Column(
                children: <Widget>[
                  DatePicker(),
                  TimePicker(),
                ],
              ),
            ),
            BackDrop(),
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
