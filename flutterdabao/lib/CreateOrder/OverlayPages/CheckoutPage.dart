import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutterdabao/CreateOrder/OrderNow.dart';
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
import 'package:flutterdabao/Model/Voucher.dart';
import 'package:flutterdabao/OrderItems/OrderItemSummary.dart';
import 'package:flutterdabao/Rewards/MyVoucherPage.dart';
import 'package:flutterdabao/Rewards/SearchPromoCodePage.dart';
import 'package:rxdart/rxdart.dart';

class CheckoutPage extends StatefulWidget {
  final OrderHolder holder;
  final VoidCallback checkout;
  CheckoutPage({Key key, this.holder, @required this.checkout})
      : super(key: key);

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

  MutableProperty<double> finalPriceProperty;

  MutableProperty<double> discountDeliveryFee;

  String promoCodeError;
  @override
  void initState() {
    super.initState();

    actualDeliveryFeeProperty = widget.holder.deliveryFee;

    discountDeliveryFee = widget.holder.voucherDeliveryFeeDiscount;

    finalPriceProperty = widget.holder.finalPrice;

    subscription.add(suggestedDeliveryFeeProperty.bindTo(
        Observable.combineLatest2<double, double, double>(
            widget.holder.orderItems.producer
                .map((items) => ConfigHelper.instance.deliveryFeeCalculator(
                        numberOfItems: items.map((item) {
                      return item.quantity.value;
                    }).reduce((qty1, qty2) => qty1 + qty2))),
            discountDeliveryFee.producer,
            (suggestedPrice, deliveryFeeDiscount) {
      if (deliveryFeeDiscount == null) return suggestedPrice;

      return max(deliveryFeeDiscount, suggestedPrice);
    })));

    subscription.add(actualDeliveryFeeProperty.bindTo(Observable.combineLatest2(
        suggestedDeliveryFeeProperty.producer,
        chosenPercentage.producer,
        (suggested, percentage) => suggested * percentage)));

    subscription.add(Observable.combineLatest2<String, Voucher, String>(
        widget.holder.foodTag.producer, widget.holder.voucherProperty.producer,
        (foodTag, voucher) {
      if (voucher == null || voucher.foodTag.value == null) return null;

      if (foodTag.toLowerCase() != voucher.foodTag.value.toLowerCase()) {
        return "This promo code is only applicable for ${voucher.foodTag.value}";
      } else {
        return null;
      }
    }).listen((error) {
      setState(() {
        promoCodeError = error;
      });
    }));
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
            buildCompleteButton()
          ],
        )));
  }

  StreamBuilder<List<OrderItemHolder>> buildCompleteButton() {
    return StreamBuilder<List<OrderItemHolder>>(
      stream: widget.holder.orderItems.producer,
      builder: (context, snap) {
        if (snap.hasData && snap.data.length > 0)
          return Container(
            padding: EdgeInsets.only(
                left: 12.0, right: 12.0, bottom: 20.0, top: 0.0),
            child: ArrowButton(
              title: "Checkout",
              onPressedCallback: () {
                if (promoCodeError == null)
                  widget.checkout();
                else {
                  final snackBar =
                      SnackBar(content: Text('This Promo Code cannot be used'));
                  Scaffold.of(context).showSnackBar(snackBar);
                }
              },
            ),
          );
        else
          return Container();
      },
    );
  }

  Widget buildPromoCode() {
    return GestureDetector(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          "Promo Code",
                          style: FontHelper.bold(Colors.black, 14.0),
                        ),
                        Expanded(
                            child: Align(
                          alignment: Alignment.centerRight,
                          child: StreamBuilder<Voucher>(
                            stream: widget.holder.voucherProperty.producer,
                            builder: (BuildContext context, snapshot) {
                              if (!snapshot.hasData || snapshot.data == null)
                                return Icon(Icons.arrow_forward_ios);

                              return StreamBuilder<String>(
                                  stream: snapshot.data.code,
                                  builder: (context, snap) {
                                    if (!snap.hasData || snap.data == null)
                                      return Offstage();

                                    return Text(
                                      snap.data,
                                      style: FontHelper.bold(
                                          promoCodeError == null
                                              ? ColorHelper.dabaoOrange
                                              : ColorHelper.dabaoErrorRed,
                                          14.0),
                                    );
                                  });
                            },
                          ),
                        )),
                      ],
                    ),
                    StreamBuilder<Voucher>(
                      stream: widget.holder.voucherProperty.producer,
                      builder: (BuildContext context, snapshot) {
                        if (!snapshot.hasData || snapshot.data == null)
                          return Offstage();

                        return Row(
                          children: <Widget>[
                            Text(
                              "Delivery Fee Discount:",
                              style: FontHelper.medium(
                                  promoCodeError == null
                                      ? Colors.black
                                      : ColorHelper.dabaoErrorRed,
                                  12.0),
                            ),
                            Expanded(
                                child: Align(
                              alignment: Alignment.centerRight,
                              child: StreamBuilder<double>(
                                stream: snapshot.data.deliveryFeeDiscount,
                                builder: (BuildContext context, snapshot) {
                                  if (snapshot.data == null) {
                                    return Offstage();
                                  }
                                  return Text(
                                    "- ${StringHelper.doubleToPriceString(snapshot.data)}",
                                    style: FontHelper.medium(
                                        promoCodeError == null
                                            ? Colors.black
                                            : ColorHelper.dabaoErrorRed,
                                        12.0),
                                  );
                                },
                              ),
                            ))
                          ],
                        );
                      },
                    ),
                    promoCodeError == null
                        ? Offstage()
                        : Row(
                            children: <Widget>[
                              Text(
                                "Error:",
                                style: FontHelper.medium(ColorHelper.dabaoErrorRed, 12.0),
                              ),
                              Expanded(
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        promoCodeError,
                                        style: FontHelper.medium(
                                            promoCodeError == null
                                                ? Colors.black
                                                : ColorHelper.dabaoErrorRed,
                                            12.0),
                                      )))
                            ],
                          )
                  ],
                ),
              ),
            ),
            StreamBuilder(
              stream: widget.holder.voucherProperty.producer,
              builder: (context, snap) {
                if (!snap.hasData || snap.data == null) return Offstage();

                return GestureDetector(
                  onTap: () {
                    widget.holder.voucherProperty.value = null;
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.only(left: 10.0),
                    child: Container(
                      child: Icon(Icons.add_circle_outline),
                      transform: new Matrix4.rotationZ(pi / 4),
                    ),
                  ),
                );
              },
            )
          ],
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => new VoucherApplicationPage(
                    voucherProperty: widget.holder.voucherProperty,
                  )));
        });
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
