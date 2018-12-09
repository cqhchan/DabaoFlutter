import 'package:flutter/material.dart';
import 'package:flutterdabao/CreateOrder/OrderNow.dart';

class CreateOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          OrderNow(),
        ],
      ),
    );
  }
}
