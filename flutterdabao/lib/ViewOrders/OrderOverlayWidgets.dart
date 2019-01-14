import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/Line.dart';
import 'package:flutterdabao/ExtraProperties/HavingSubscriptionMixin.dart';
import 'package:flutterdabao/HelperClasses/ColorHelper.dart';
import 'package:flutterdabao/HelperClasses/DateTimeHelper.dart';
import 'package:flutterdabao/HelperClasses/FontHelper.dart';
import 'package:flutterdabao/HelperClasses/ReactiveHelpers/rx_helpers.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:flutterdabao/Model/Order.dart';
import 'package:flutterdabao/Model/OrderItem.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;

class DeliveryLocation extends StatelessWidget {
  final Order order;

  const DeliveryLocation({Key key, this.order}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _buildLocationDescription(order);
  }

  Row _buildLocationDescription(Order order) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
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
}

class DateTimePicker extends StatefulWidget {
  final Order order;
  final Function(DateTime) selectedTimeCallback;
  final Function(DateTime) startTime;
  final Function(DateTime) endTime;

  const DateTimePicker(
      {Key key,
      this.order,
      @required this.selectedTimeCallback,
      @required this.startTime,
      @required this.endTime})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DateTimePickerState();
  }
}

class _DateTimePickerState extends State<DateTimePicker>
    with HavingSubscriptionMixin {
  DateTime startTime;
  DateTime endTime;
  MutableProperty<DateTime> selectedDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    DateTime currentTime = DateTime.now();

    widget.order.mode.where((mode) => mode != null).first.then((mode) {
      switch (mode) {
        case OrderMode.asap:
          setState(() {
            endTime = widget.order.endDeliveryTime.value == null
                ? currentTime.add(Duration(minutes: 90))
                : widget.order.endDeliveryTime.value;
            startTime = currentTime.isAfter(endTime)
                ? endTime.subtract(Duration(minutes: 60))
                : currentTime;
          });

          break;
        case OrderMode.scheduled:
          setState(() {
            endTime = widget.order.endDeliveryTime.value;
            startTime = widget.order.startDeliveryTime.value;
          });

          break;
      }

      widget.startTime(startTime);
      widget.endTime(endTime);

      //Copy to prevent editting
      selectedDate = MutableProperty(DateTime.fromMillisecondsSinceEpoch(
          startTime.millisecondsSinceEpoch + 1000));

      subscription.add(selectedDate.producer.listen((selectedTime) {
        widget.selectedTimeCallback(selectedTime);
      }));
    });
  }

  @override
  void dispose() {
    disposeAndReset();
    super.dispose();
  }

  Widget _buildArrivalTime(Order order) {
    if (startTime == null || endTime == null) {
      return Text("ERROR");
    }
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
        GestureDetector(
          onTap: () async {
            // if (Platform.isIOS) {

            await showModalBottomSheet(
                context: context,
                builder: (context) {
                  return CupertinoDatePicker(
                    use24hFormat: true,
                    initialDateTime: selectedDate.value.isBefore(startTime)
                        ? startTime
                        : selectedDate.value.isAfter(endTime)
                            ? endTime
                            : selectedDate.value,
                    mode: CupertinoDatePickerMode.dateAndTime,
                    onDateTimeChanged: (DateTime newDateTime) {
                      selectedDate.value = newDateTime;
                    },
                    minimumDate: DateTimeHelper.sameDay(startTime, endTime)
                        ? startTime
                        : startTime.subtract(Duration(days: 1)),
                    maximumDate: endTime,
                  );
                });
          },
          child: StreamBuilder<DateTime>(
            stream: selectedDate.producer,
            builder: (context, snap) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                      width: 140,
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                              snap.data != null
                                  ? DateTimeHelper.hourAndMin12Hour(snap.data)
                                  : "00:00",
                              style: FontHelper.semiBold(Colors.black, 45)))),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                          snap.data != null
                              ? formatDate(snap.data, [am])
                              : "AM",
                          style: FontHelper.semiBold(Colors.black, 22)),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryPeriod(Order order) {
    if (startTime == null || endTime == null) {
      return Text("ERROR");
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          DateTimeHelper.convertDoubleTimeToDisplayString(startTime,endTime),
          style: FontHelper.semiBold14Black,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildDeliveryPeriod(widget.order),
        _buildArrivalTime(widget.order),
      ],
    );
  }
}
