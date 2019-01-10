import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/LoaderAnimator/LoadingWidget.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/Firebase/FirebaseCloudFunctions.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/ConfigHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/TimePicker/ScrollableHourPicker.dart';
import 'package:flutterdabao/TimePicker/ScrollableMinutePicker.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;
import 'dart:core';

import 'package:flutterdabao/ViewOrders/OrderOverlayWidgets.dart';

class ConfirmationOverlay extends StatefulWidget {
  final Order order;
  final DabaoRoute.Route route;

  const ConfirmationOverlay({Key key, @required this.order, this.route})
      : super(key: key);
  _ConfirmationOverlayState createState() => _ConfirmationOverlayState();
}

class _ConfirmationOverlayState extends State<ConfirmationOverlay>
    with HavingSubscriptionMixin {
  MutableProperty<List<OrderItem>> listOfOrderItems = MutableProperty(List());

  DateTime selectedDateTime;
  DateTime startTime;
  DateTime endTime;

  @override
  void initState() {
    super.initState();
    listOfOrderItems = widget.order.orderItem;
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
                          _buildHeader(widget.order),
                          SizedBox(
                            height: 15,
                          ),
                          DeliveryLocation(order: widget.order),
                          SizedBox(
                            height: 15,
                          ),
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
                                  child:
                                      _buildPickUpButton(widget.order, context),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        ));
  }

  Flex _buildHeader(Order order) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: StreamBuilder<String>(
                  stream: widget.order.foodTag,
                  builder: (context, snap) {
                    if (!snap.hasData) return Offstage();
                    return Text(
                      StringHelper.upperCaseWords(snap.data),
                      style: FontHelper.semiBold16Black,
                    );
                  },
                ),
              ),
              SizedBox(
                height: 11.0,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              StreamBuilder<double>(
                stream: widget.order.deliveryFee,
                builder: (context, snap) {
                  if (!snap.hasData) return Offstage();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        StringHelper.doubleToPriceString(
                          snap.data,
                        ),
                        style: FontHelper.bold14Black,
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
              StreamBuilder<List<OrderItem>>(
                stream: listOfOrderItems.producer,
                builder: (context, snap) {
                  if (!snap.hasData) return Offstage();
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 26.0),
                      child: Text(
                        snap.hasData ? '${snap.data.length} Item(s)' : "Error",
                        style: FontHelper.medium14TextStyle,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPickUpButton(Order order, BuildContext context) {
    return RaisedButton(
      elevation: 12,
      color: ColorHelper.dabaoOffPaleBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: Text(
          "Confirm",
          style: FontHelper.semiBold14White,
        ),
      ),
      onPressed: () async {
        print(selectedDateTime);

        if (selectedDateTime
                .isAfter(startTime.subtract(Duration(minutes: 9))) &&
            selectedDateTime.isBefore(endTime.add(Duration(minutes: 9)))) {
          order.isSelectedProperty.value = false;
          showLoadingOverlay(context: context);
          var isSuccessful = await FirebaseCloudFunctions.acceptOrder(
            routeID: widget.route == null ? null : widget.route.uid,
            orderID: widget.order.uid,
            acceptorID: ConfigHelper.instance.currentUserProperty.value.uid,
            deliveryTime:
                DateTimeHelper.convertDateTimeToString(selectedDateTime),
          );
          if (isSuccessful) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pop();
            final snackBar = SnackBar(
                content: Text(
                    'An Error has occured. Please check your network connectivity'));
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
          style: FontHelper.semiBold14Black2,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}
