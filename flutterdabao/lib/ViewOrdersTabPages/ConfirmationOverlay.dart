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
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;
import 'dart:core';

import 'package:flutterdabao/ViewOrders/OrderOverlayWidgets.dart';
import 'package:rxdart/rxdart.dart';

class ConfirmationOverlay extends StatefulWidget {
  final Order order;
  final DabaoRoute.Route route;
  final VoidCallback onCompletionCallback;

  const ConfirmationOverlay(
      {Key key, @required this.order, this.route, this.onCompletionCallback})
      : super(key: key);
  _ConfirmationOverlayState createState() => _ConfirmationOverlayState();
}

class _ConfirmationOverlayState extends State<ConfirmationOverlay>
    with HavingSubscriptionMixin {
  MutableProperty<List<OrderItem>> listOfOrderItems = MutableProperty(List());

  MutableProperty<DateTime> selectedDateTime = MutableProperty(null);
  MutableProperty<DateTime> startTime = MutableProperty(null);
  MutableProperty<DateTime> endTime = MutableProperty(null);
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    listOfOrderItems = widget.order.orderItem;

    subscription.add(
        Observable.combineLatest3<DateTime, DateTime, DateTime, String>(
            selectedDateTime.producer, startTime.producer, endTime.producer,
            (selected, start, end) {
      if (selected.isBefore(start) || selected.isAfter(end)) {
        return 'Delivery Time Selected must be between ${DateTimeHelper.convertDoubleTimeToDisplayString(start, end)}';
      }
      return "";
    }).listen((error) {
      setState(() {
        errorMessage = error;
      });
    }));
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  //TODO p2 add succcess dialog
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
                              selectedDateTime.value = selected;
                            },
                            endTime: (DateTime end) {
                              endTime.value = end;
                            },
                            startTime: (DateTime start) {
                              startTime.value = start;
                            },
                          ),
                          // this is the food tag
                          _buildHeader(widget.order),
                          SizedBox(
                            height: 15,
                          ),
                          DeliveryLocation(order: widget.order),
                          SizedBox(
                            height: 15,
                          ),
                          Offstage(
                            offstage: errorMessage.isEmpty,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(0.0, 10, 0.0, 10),
                              child: Text(
                                errorMessage,
                                style: FontHelper.semiBold(
                                    ColorHelper.dabaoErrorRed, 12.0),
                                textAlign: TextAlign.center,
                              ),
                            ),
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
      child: Container(
        height: 40,
        child: Center(
          child: Text(
            "Confirm",
            style: FontHelper.semiBold14White,
          ),
        ),
      ),
      onPressed: () async {
        if (selectedDateTime.value
                .isAfter(startTime.value.subtract(Duration(minutes: 9))) &&
            selectedDateTime.value
                .isBefore(endTime.value.add(Duration(minutes: 9)))) {
          order.isSelectedProperty.value = false;
          showLoadingOverlay(context: context);
          var isSuccessful = await FirebaseCloudFunctions.acceptOrder(
            routeID: widget.route == null ? null : widget.route.uid,
            orderID: widget.order.uid,
            acceptorID: ConfigHelper.instance.currentUserProperty.value.uid,
            deliveryTime:
                DateTimeHelper.convertDateTimeToString(selectedDateTime.value),
          );
          if (isSuccessful) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();

            if (widget.onCompletionCallback != null)
              widget.onCompletionCallback();
          } else {
            Navigator.of(context).pop();
            final snackBar = SnackBar(
                content: Text(
                    'An Error has occured. Please check your network connectivity'));
            Scaffold.of(context).showSnackBar(snackBar);
          }
        } else {
          setState(() {
            errorMessage =
                'Delivery Time Selected must be between ${DateTimeHelper.convertDoubleTimeToDisplayString(startTime.value, endTime.value)}';
          });
        }
      },
    );
  }

  Widget _buildBackButton() {
    return OutlineButton(
      color: Colors.transparent,
      borderSide: BorderSide(color: Colors.black),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        height: 40,
        child: Center(
          child: Text(
            "Back",
            style: FontHelper.semiBold14Black2,
          ),
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}
