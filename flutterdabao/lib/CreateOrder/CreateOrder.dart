import 'package:flutter/material.dart';

import 'package:flutterdabao/CreateOrder/OrderNow.dart';
import 'package:flutterdabao/CustomWidget/CustomizedBackButton.dart';
import 'package:flutterdabao/CustomWidget/CustomizedMap.dart';

class CreateOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          CustomizedMap(),
          OrderNow(),
          CustomizedBackButton(),
        ],
      ),
    );
  }
}
