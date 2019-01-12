import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Channels.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/ViewOrders/OrderOverlayWidgets.dart';

class CounterOfferOverlay extends StatefulWidget {
  final Order order;
  final Channel channel;

  const CounterOfferOverlay(
      {Key key, @required this.order, @required this.channel})
      : super(key: key);
  _CounterOfferOverlayState createState() => _CounterOfferOverlayState();
}

class _CounterOfferOverlayState extends State<CounterOfferOverlay>
    with HavingSubscriptionMixin {
  MutableProperty<List<OrderItem>> listOfOrderItems = MutableProperty(List());

  //selected date on press
  DateTime selectedDateTime;
  DateTime startTime;
  DateTime endTime;
  MutableProperty<double> _sliderSelector = MutableProperty<double>(null);
  double startingValue;

  @override
  void initState() {
    super.initState();
    listOfOrderItems = widget.order.orderItem;

    widget.order.deliveryFee
        .where((fee) => fee != null)
        .take(1)
        .first
        .then((value) {
      _sliderSelector.value = value;

      setState(() {
        startingValue = value;
      });
    });
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Builder(
            builder: (context) => Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.white,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _buildHeader(),
                          Line(
                            margin: EdgeInsets.only(top: 10.0, bottom: 5.0),
                          ),
                          DateTimePicker(
                            order: widget.order,
                            selectedTimeCallback: (DateTime selected) {
                              selectedDateTime = selected;
                            },
                            endTime: (DateTime end) {
                              endTime = end;
                            },
                            startTime: (DateTime start) {
                              startTime = start;
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          DeliveryLocation(order: widget.order),
                          Line(
                            margin: EdgeInsets.only(top: 20.0, bottom: 5.0),
                          ),
                          _buildCurrentFee(),
                          Line(
                            margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                          ),
                          _buildSlider(),
                          SizedBox(
                            height: 10,
                          ),
                          _buildOffer(),
                          Flex(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            verticalDirection: VerticalDirection.up,
                            direction: Axis.horizontal,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: _buildBackButton(),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: _buildConfirmButton(
                                      widget.order, context),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ))));
  }

  Widget _buildHeader() {
    return Text(
      'Counter-Offer Deliver Fee',
      style: FontHelper.semiBold16Black,
    );
  }

  Widget _buildCurrentFee() {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(
          child: Text(
            'Current Delivery Fee',
            style: FontHelper.bold12Black,
          ),
        ),
        Expanded(
          child: StreamBuilder<double>(
            stream: widget.order.deliveryFee,
            builder: (context, snap) {
              if (!snap.hasData) return Offstage();
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    snap.hasData
                        ? StringHelper.doubleToPriceString(snap.data)
                        : "Error",
                    style: FontHelper.regular12Black,
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(
                    width: 2.0,
                  ),
                  Image.asset('assets/icons/question_mark.png'),
                ],
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildSlider() {
    if (startingValue == null) return Offstage();
    return Column(
      children: <Widget>[
        StreamBuilder<double>(
            stream: _sliderSelector.producer,
            builder: (context, snap) {
              if (!snap.hasData || snap.data == null) return Offstage();

              return Container(
                color: Color(0xFFF3F3F3),
                child: Slider(
                  activeColor: Color(0xFFBCE0FD),
                  inactiveColor: Colors.white,
                  divisions: 6,
                  max: ((startingValue.roundToDouble() - 1.5) < 0
                          ? 0
                          : startingValue.roundToDouble()) +
                      3.0,
                  min: ((startingValue.roundToDouble() - 1.5) < 0
                      ? 0
                      : startingValue.roundToDouble() -1.5),
                  value: snap.data,
                  onChanged: (data) {
                    _sliderSelector.value = data;
                  },
                ),
              );
            }),
        Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(
                  ((startingValue.roundToDouble() - 1.5) < 0
                      ? 0
                      : startingValue.roundToDouble() - 1.5)),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(
                  ((startingValue.roundToDouble() - 1.5) < 0
                          ? 0
                          :startingValue.roundToDouble() - 1.5) +
                      0.5),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(
                  ((startingValue.roundToDouble() - 1.5) < 0
                          ? 0
                          : startingValue.roundToDouble() - 1.5) +
                      1.0),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(
                  ((startingValue.roundToDouble() - 1.5) < 0
                          ? 0
                          : startingValue.roundToDouble() - 1.5) +
                      1.5),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(
                  ((startingValue.roundToDouble() - 1.5) < 0
                          ? 0
                          : startingValue.roundToDouble() - 1.5) +
                      2.0),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(
                  ((startingValue.roundToDouble() - 1.5) < 0
                          ? 0
                          : startingValue.roundToDouble() - 1.5) +
                      2.5),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
            Expanded(
                child: Text(
              StringHelper.doubleToPriceString(
                  ((startingValue.roundToDouble() - 1.5) < 0
                          ? 0
                          : startingValue.roundToDouble() - 1.5) +
                      3.0),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.center,
            )),
          ],
        )
      ],
    );
  }

  Widget _buildOffer() {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(
          child: Text(
            'Your Offer',
            style: FontHelper.bold12Black,
          ),
        ),
        StreamBuilder<double>(
          stream: _sliderSelector.producer,
          builder: (context, snap) {
            if (!snap.hasData || snap.data == null) return Offstage();
            return Expanded(
                child: Text(
              StringHelper.doubleToPriceString(snap.data),
              style: FontHelper.regular12Black,
              textAlign: TextAlign.right,
            ));
          },
        ),
      ],
    );
  }

  Widget _buildConfirmButton(Order order, BuildContext context) {
    return RaisedButton(
      elevation: 12,
      color: Color(0xFF959DAD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: Text(
          "Offer",
          style: FontHelper.semiBold14White,
        ),
      ),
      onPressed: () async {
        print(selectedDateTime);

        if (selectedDateTime
                .isAfter(startTime.subtract(Duration(minutes: 9))) &&
            selectedDateTime.isBefore(endTime.add(Duration(minutes: 9)))) {
          if (_sliderSelector.value != null) {
            widget.channel.setCounterOffer(
                _sliderSelector.value,
                selectedDateTime,
                ConfigHelper.instance.currentUserProperty.value.uid);
            widget.channel.addMessage(
                "${ConfigHelper.instance.currentUserProperty.value.name.value} " +
                    "has offered to pick up your order! " +
                    "\nDeliver at: ${DateTimeHelper.convertTimeToDisplayString(selectedDateTime)} " +
                    "\nCounter-Offer Delivery Fee to:${StringHelper.doubleToPriceString(_sliderSelector.value)}",
                ConfigHelper.instance.currentUserProperty.value.uid,
                null);
            Navigator.of(context).pop();
          } else {
            final snackBar =
                SnackBar(content: Text('Select a valid counter offer fee'));
            Scaffold.of(context).showSnackBar(snackBar);
          }
        } else {
          final snackBar = SnackBar(
              content: Text(
                  'Delivery Time must be between ${DateTimeHelper.convertDoubleTime2ToDisplayString(startTime, endTime)}'));
          Scaffold.of(context).showSnackBar(snackBar);
        }
      },
    );
  }

  Widget _buildBackButton() {
    return RaisedButton(
      elevation: 12,
      color: ColorHelper.dabaoOffWhiteF5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: Text(
          "Back",
          style: FontHelper.semiBold14Black,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}

class _DeliveryLocation {}
