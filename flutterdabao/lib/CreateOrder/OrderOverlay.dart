import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/CreateOrder/FoodTag.dart';
import 'package:flutterdabao/CustomWidget/Headers/DoubleLineHeader.dart';
import 'package:flutterdabao/CustomWidget/page_turner_widget.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:rxdart/src/subjects/behavior_subject.dart';

class OrderOverlay extends StatefulWidget {
  final MutableProperty<int> page;
  final OrderHolder holder;

  OrderOverlay({@required this.page, @required this.holder});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _OrderOverlayState();
  }
}

class _OrderOverlayState extends State<OrderOverlay> with PageHandler {
  @override
  BehaviorSubject<int> get pageNumberSubject => widget.page.producer;

  @override
  Widget pageForNumber(int pageNumber) {
    switch (pageNumber) {
      case 0:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DoubleLineHeader(
              title: "Food Tag",
              subtitle: "Select one",
            ),
            FoodTag()
          ],
        );

      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DoubleLineHeader(
              title: "",
            ),
            GestureDetector(
              onTap: () => pageNumberSubject.add(pageNumber + 1),
              child: Container(
                color: Colors.white,
                height: 100.0 * pageNumber,
                width: MediaQuery.of(context).size.width,
              ),
            )
          ],
        );
    }

    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageTurner(this);
  }
}
