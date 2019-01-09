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

  //selected date on press
  MutableProperty<DateTime> selectedDate;

  HourPicker hourPicker;
  MinutePicker minutePicker;

  DateTime startTime;
  DateTime endTime;

  @override
  void initState() {
    super.initState();
    listOfOrderItems = widget.order.orderItem;

    DateTime currentTime = DateTime.now();

    subscription.add(widget.order.mode.listen((mode) {
      switch (mode) {
        case OrderMode.asap:
          setState(() {
            endTime = widget.order.endDeliveryTime.value == null
                ? currentTime.add(Duration(minutes: 90))
                : widget.order.endDeliveryTime.value;
            startTime = currentTime.isAfter(endTime) ? endTime : currentTime;
          });

          break;
        case OrderMode.scheduled:
          setState(() {
            endTime = widget.order.endDeliveryTime.value;
            startTime = widget.order.startDeliveryTime.value;
          });

          break;
      }

      //Copy to prevent editting
      selectedDate = MutableProperty(DateTime.fromMillisecondsSinceEpoch(
          startTime.millisecondsSinceEpoch));
    }));
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  //Minute change is dependant on the hour change.
  _handleHour(num hour) {
    DateTime newDate = new DateTime(
        startTime.year,
        startTime.month,
        startTime.day,
        startTime.hour + hour,
        selectedDate.value.minute,
        selectedDate.value.second,
        selectedDate.value.millisecond);

    selectedDate.value = newDate;
  }

  _handleMinuteChanged(num minute) {
    selectedDate.value = new DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        selectedDate.value.hour,
        minute,
        selectedDate.value.second,
        selectedDate.value.millisecond);
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
                          _buildDeliveryPeriod(widget.order),
                          _buildArrivalTime(widget.order),
                          _buildHeader(widget.order),
                          SizedBox(
                            height: 15,
                          ),
                          _buildLocationDescription(widget.order),
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

  Row _buildDeliveryPeriod(Order order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        (startTime.day == DateTime.now().day &&
                startTime.month == DateTime.now().month &&
                startTime.year == DateTime.now().year)
            ? Text(
                'Today, ' + DateTimeHelper.convertDateTimeToAMPM(startTime),
                style: FontHelper.semiBold14Black,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                DateTimeHelper.convertDateTimeToDate(startTime) +
                    ', ' +
                    DateTimeHelper.convertDateTimeToAMPM(startTime),
                style: FontHelper.semiBold14Black,
                overflow: TextOverflow.ellipsis,
              ),
        Container(
            child: Text( " - " +
              DateTimeHelper.convertDateTimeToAMPM(endTime),
              style: FontHelper.semiBold14Black,
              overflow: TextOverflow.ellipsis,
            )),
      ],
    );
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

  Row _buildLocationDescription(Order order) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            right: 5,
          ),
          child: Container(
            height: 30,
            child: Image.asset("assets/icons/red_marker_icon.png"),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder<String>(
              stream: order.deliveryLocationDescription,
              builder: (context, snap) {
                if (!snap.hasData) return Offstage();
                return Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 180),
                  child: Text(
                    snap.hasData ? '''${snap.data}''' : "Error",
                    style: FontHelper.regular14Black,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ],
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
        print(selectedDate.value);

        if (selectedDate.value
                .isAfter(startTime.subtract(Duration(minutes: 9))) &&
            selectedDate.value.isBefore(endTime.add(Duration(minutes: 9)))) {
          order.isSelectedProperty.value = false;
          showLoadingOverlay(context: context);
          var isSuccessful = await FirebaseCloudFunctions.acceptOrder(
            routeID: widget.route == null ? null : widget.route.uid,
            orderID: widget.order.uid,
            acceptorID: ConfigHelper.instance.currentUserProperty.value.uid,
            deliveryTime:
                DateTimeHelper.convertDateTimeToString(selectedDate.value),
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

  Widget _buildArrivalTime(Order order) {
    if (startTime == null || endTime == null) {
      return Text("ERROR");
    }
    print("testing Max : " +
        (startTime.hour + (endTime.difference(startTime).inMinutes / 60).ceil())
            .toString());
    print("testing init : " +
        (startTime.hour + selectedDate.value.difference(startTime).inHours)
            .toString());

    return Row(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(minHeight: 20, minWidth: 40),
          child: Text(
            'I can arrive by: ',
            style: FontHelper.regular14Black,
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        HourPicker.hour(
          maxValue: startTime.hour +
              (endTime.difference(startTime).inMinutes / 60).ceil(),
          minValue: startTime.hour,
          initialValue:
              startTime.hour + selectedDate.value.difference(startTime).inHours,
          onChanged: (value) {
            print(value);
            _handleHour(value);
          },
        ),
        Text(':', style: FontHelper.robotoRegular50Black),
        MinutePicker.minute(
          maxValue: 5,
          minValue: 0,
          initialValue: selectedDate.value.minute ~/ 10,
          step: 1,
          onChanged: (value) {
            _handleMinuteChanged(value * 10);
          },
        ),
      ],
    );
  }
}
