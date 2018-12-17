import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdabao/CreateOrder/OverlayPages/CheckoutPage.dart';
import 'package:flutterdabao/CreateOrder/OverlayPages/SelectFoodTagPage.dart';
import 'package:flutterdabao/CreateOrder/OverlayPages/SelectOrderItem.dart';
import 'package:flutterdabao/CustomWidget/Headers/DoubleLineHeader.dart';
import 'package:flutterdabao/CustomWidget/page_turner_widget.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/MutableProperty.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:rxdart/src/subjects/behavior_subject.dart';

class OrderOverlay extends StatefulWidget {
  final MutableProperty<int> page;
  final OrderHolder holder;
  final MutableProperty<bool> checkout;

  OrderOverlay(
      {@required this.page, @required this.holder, @required this.checkout});

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
              closeTapped: backToLocationCard,
              title: widget.holder.deliveryLocationDescription.value,
              subtitle: "Today,",
            ),
            Flexible(
                child: SelectFoodTagPage(
                  holder: widget.holder,
                  nextPage: nextPage,
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
              closeTapped: backToLocationCard,
              headerTapped: backEraseOrderItemWarning,
              leftButton: GestureDetector(
                onTap: backEraseOrderItemWarning,
                child: Container(
                    padding: EdgeInsets.only(left: 16.0),
                    height: 20,
                    width: 30,
                    child: Image.asset("assets/icons/arrow_left_icon.png")),
              ),
              title: StringHelper.upperCaseWords(widget.holder.foodTag.value),
            ),
            Flexible(
                child: SelectOrderItem(
                  holder: widget.holder,
                  nextPage: nextPage,
                ),
              ),
          ],
        );
        break;

      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DoubleLineHeader(
              closeTapped: backToLocationCard,
              headerTapped: previousPage,
              leftButton: GestureDetector(
                onTap: previousPage,
                child: Container(
                    margin: EdgeInsets.only(left: 16.0),
                    height: 20,
                    width: 15,
                    child: Image.asset("assets/icons/arrow_left_icon.png")),
              ),
              title: "Checkout",
            ),
            Flexible(
              child: SingleChildScrollView(
                child: CheckoutPage(
                  holder: widget.holder, checkout: toCheckout,
                ),
              ),
            )
          ],
        );
        break;
    }
  }

  backToLocationCard() {
    widget.checkout.value = false;
    Navigator.of(context).pop();
  }

  toCheckout() {
    widget.checkout.value = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PageTurner(this);
  }

  backEraseOrderItemWarning() {
    //Display Warning all OrderItems will be deleted
    if (widget.holder.orderItems.value.length > 0) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Go back?"),
              content: Text("Your current order items will be deleted"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                    "Leave",
                    style: FontHelper.bold(ColorHelper.dabaoOrange, 16.0),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.holder.orderItems.value = List();
                    previousPage();
                  },
                ),
                new FlatButton(
                  child: new Text(
                    "Stay",
                    style: FontHelper.regular(Colors.black, 14.0),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    } else {
      previousPage();
    }
  }

  @override
  // TODO: implement maxPage
  int get maxPage => 2;
}
