import 'package:flutter/material.dart';
// import 'package:flutterbackdrop/home_page.dart';
import 'package:flutterdabao/CreateOrder/TwoPanels.dart';
// import 'package:flutter/services.dart';

class BackDrop extends StatefulWidget {
  @override
  _BackDropState createState() => new _BackDropState();
}

class _BackDropState extends State<BackDrop>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 100), value: 1.0);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  bool get isPanelVisible {
    final AnimationStatus status = controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Create Order"),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              controller.fling(velocity: isPanelVisible ? -1.0 : 1.0);
            },
            icon: new AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: controller.view,
            ),
          ),
        ],
      ),
      body: new TwoPanels(
        controller: controller,
      ),
    );
  }
}
