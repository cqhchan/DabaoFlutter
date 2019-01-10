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
import 'package:flutterdabao/TimePicker/ScrollableHourPicker.dart';
import 'package:flutterdabao/TimePicker/ScrollableMinutePicker.dart';

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
      {Key key, this.order, @required this.selectedTimeCallback, @required this.startTime,@required this.endTime})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DateTimePickerState();
  }
}

class _DateTimePickerState extends State<DateTimePicker>
    with HavingSubscriptionMixin {
  HourPicker hourPicker;
  MinutePicker minutePicker;

  DateTime startTime;
  DateTime endTime;
  MutableProperty<DateTime> selectedDate;

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

      widget.startTime(startTime);
      widget.endTime(endTime);

      //Copy to prevent editting
      selectedDate = MutableProperty(DateTime.fromMillisecondsSinceEpoch(
          startTime.millisecondsSinceEpoch));

      subscription.add(selectedDate.producer
          .listen((selectedTime) => widget.selectedTimeCallback(selectedTime)));
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
        HourPicker.hour(
          maxValue: startTime.hour +
              (endTime.difference(startTime).inMinutes / 60).ceil() ,
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

  Widget _buildDeliveryPeriod(Order order) {
    if (startTime == null || endTime == null) {
      return Text("ERROR");
    }
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
            child: Text(
          " - " + DateTimeHelper.convertDateTimeToAMPM(endTime),
          style: FontHelper.semiBold14Black,
          overflow: TextOverflow.ellipsis,
        )),
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
