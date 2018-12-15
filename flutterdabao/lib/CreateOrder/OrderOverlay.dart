import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/CreateOrder/OverlayPages/SelectFoodTagPage.dart';
import 'package:flutterdabao/CreateOrder/OverlayPages/SelectOrderItem.dart';
import 'package:flutterdabao/CustomWidget/Headers/DoubleLineHeader.dart';
import 'package:flutterdabao/CustomWidget/page_turner_widget.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
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
    if (pageNumber == null) {
      return CircularProgressIndicator();
    }

    switch (pageNumber) {
      case 0:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DoubleLineHeader(
              title: widget.holder.deliveryLocationDescription.value,
              subtitle: "Today,",
            ),
            Flexible(
              child: SingleChildScrollView(
                child: SelectFoodTagPage(
                  holder: widget.holder,
                  nextPage: nextPage,
                ),
              ),
            )
          ],
        );
        break;

      case 1:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DoubleLineHeader(
              leftButton: GestureDetector(
                onTap: previousPage,
                child: Container(
                    margin: EdgeInsets.only(left: 16.0),
                    height: 20,
                    width: 15,
                    child: Image.asset("assets/icons/arrow_left_icon.png")),
              ),
              title: StringHelper.upperCaseWords(widget.holder.foodTag.value),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: SelectOrderItem(
                  holder: widget.holder,
                  nextPage: nextPage,
                ),
              ),
            )
          ],
        );
        break;

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
  }

  @override
  Widget build(BuildContext context) {
    return PageTurner(this);
  }
}
