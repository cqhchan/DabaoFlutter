import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Buttons/ArrowButton.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Holder/OrderHolder.dart';
import 'package:flutterdabao/Holder/OrderItemHolder.dart';
import 'package:flutterdabao/OrderItems/OrderItemSummary.dart';
import 'package:rxdart/rxdart.dart';

class CheckoutPage extends StatefulWidget {
  final OrderHolder holder;
  final VoidCallback checkout;
  CheckoutPage({Key key, this.holder, @required this.checkout}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CheckoutPageState();
  }
}

class _CheckoutPageState extends State<CheckoutPage>
    with HavingSubscriptionMixin {
  MutableProperty<double> suggestedDeliveryFeeProperty = MutableProperty(0.0);
  MutableProperty<double> actualDeliveryFeeProperty;
  MutableProperty<double> chosenPercentage = MutableProperty(1.0);

  MutableProperty<double> finalPriceProperty = MutableProperty(0.0);

  @override
  void initState() {
    super.initState();

    actualDeliveryFeeProperty = widget.holder.deliveryFee;

    subscription.add(suggestedDeliveryFeeProperty.bindTo(
        widget.holder.orderItems.producer.map((items) => ConfigHelper.instance
            .deliveryFeeCalculator(numberOfItems: items.map((item){
              return item.quantity.value;
            }).reduce((qty1,qty2)=> qty1 + qty2)))));

    subscription.add(actualDeliveryFeeProperty.bindTo(Observable.combineLatest2(
        suggestedDeliveryFeeProperty.producer,
        chosenPercentage.producer,
        (suggested, percentage) => suggested * percentage)));

    subscription.add(finalPriceProperty.bindTo(Observable.combineLatest2(
        widget.holder.maxPrice.producer,
        actualDeliveryFeeProperty.producer,
        (price, delvieryFee) => price + delvieryFee)));
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
        padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
        color: ColorHelper.dabaoOffWhiteF5,
        child: SafeArea(
            child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(bottom: 8.0),
                child: OrderItemSummary(
                  holders: widget.holder,
                  showAddItem: false,
                  minHeight: 0.0,
                  showSummaryPrice: true,
                )),
            buildPrice(),
            buildPriceSlider(theme),
            Line(
              margin: EdgeInsets.only(left: 8.0, right: 8.0),
            ),
            buildPromoCode(),
            Line(
              margin: EdgeInsets.only(left: 8.0, right: 8.0),
            ),
            buildTotal(),
            StreamBuilder<List<OrderItemHolder>>(
              stream: widget.holder.orderItems.producer,
              builder: (context, snap) {
                if (snap.hasData && snap.data.length > 0)
                  return Container(
                    padding: EdgeInsets.only(
                        left: 12.0, right: 12.0, bottom: 20.0, top: 0.0),
                    child: ArrowButton(
                      title: "Checkout",
                      onPressedCallback: widget.checkout,
                    ),
                  );
                else
                  return Container();
              },
            )
          ],
        )));
  }

  Container buildPromoCode() {
    return Container(
      padding: EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Text(
            "Promo Code",
            style: FontHelper.bold(Colors.black, 14.0),
          )),
          Icon(Icons.arrow_forward_ios)
        ],
      ),
    );
  }

  Container buildPrice() {
    return Container(
      padding: EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Text(
            "Delivery Fee",
            style: FontHelper.bold(Colors.black, 14.0),
          )),
          StreamBuilder<double>(
            stream: actualDeliveryFeeProperty.producer,
            builder: (context, snapshot) {
              return Text(
                snapshot.hasData && snapshot.data != null
                    ? StringHelper.doubleToPriceString(snapshot.data)
                    : "\$0.00",
                style: FontHelper.regular(Colors.black, 14.0),
              );
            },
          )
        ],
      ),
    );
  }

  Container buildTotal() {
    return Container(
      padding: EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Text(
            "Order Total",
            style: FontHelper.bold(Colors.black, 14.0),
          )),
          StreamBuilder<double>(
            stream: finalPriceProperty.producer,
            builder: (context, snapshot) {

              return Text(
                snapshot.hasData && snapshot.data != null
                    ? StringHelper.doubleToPriceString(snapshot.data)
                    : "\$0.00",
                style: FontHelper.regular(Colors.black, 14.0),
              );
            },
          )
        ],
      ),
    );
  }

  Container buildPriceSlider(ThemeData theme) {
    return Container(
      height: 50.0,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.only(bottom: 5.0, left: 8.0, right: 8.0),
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("😔",
                          style: FontHelper.bold(Colors.black, 25.0)),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                    ),
                  ),
                  Text("😃", style: FontHelper.bold(Colors.black, 25.0)),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("😍",
                          style: FontHelper.bold(Colors.black, 25.0)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 20,
            child: Align(
              alignment: Alignment.topCenter,
              child: SliderTheme(
                child: Slider(
                  onChanged: (double value) {
                    setState(() {
                      chosenPercentage.value = value;
                    });
                  },
                  divisions: 15,
                  value: chosenPercentage.value,
                  max: 1.5,
                ),
                data: theme.sliderTheme
                    .copyWith(thumbShape: RoundSliderThumbShape()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
