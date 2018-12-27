import 'package:flutter/material.dart';
import 'package:flutterdabao/CustomWidget/LoaderAnimator/LoadingWidget.dart';
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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutterdabao/Model/Route.dart' as DabaoRoute;

class ConfirmationOverlay extends StatefulWidget {
  final Order order;
  final DabaoRoute.Route route;

  const ConfirmationOverlay({Key key, @required this.order, this.route})
      : super(key: key);
  _ConfirmationOverlayState createState() => _ConfirmationOverlayState();
}

class _ConfirmationOverlayState extends State<ConfirmationOverlay> {
  static const _dayMenu = <String>[
    'Today',
    'Tomorrow',
  ];

  final List<DropdownMenuItem<String>> _dropdownDayMenu = _dayMenu
      .map((String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ))
      .toList();

  DateTime isToday;
  DateTime selectedDate;
  bool past24period;

  HourPicker integerScheduledHourPicker;
  MinutePicker integerScheduledMinutePicker;
  HourPicker integerASAPHourPicker;
  MinutePicker integerASAPMinutePicker;

  int _scheduledInitialHour;
  int _scheduledInitialMinute;
  int _scheduledMaximumMinute;
  int _scheduledMinimumMinute;
  int _scheduledMaximumHour;
  int _scheduledMinimumHour;

  int _asapInitialHour;
  int _asapInitialMinute;
  int _asapMaximumMinute;
  int _asapMinimumMinute;
  int _asapMaximumHour;
  int _asapMinimumHour;

  String selectedDay = 'Today';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    assert(widget.order.deliveryFee != null);
    assert(widget.order.deliveryLocationDescription != null);
    assert(widget.order.foodTag != null);
    assert(widget.order.mode != null);
    assert(widget.order.startDeliveryTime != null);
    assert(widget.order.endDeliveryTime != null);
    assert(widget.order.orderItems != null);
    assert(widget.order.createdDeliveryTime != null);
    assert(widget.order.deliveryTime != null);
    assert(widget.order.message != null);
    assert(widget.order.deliveryLocation != null);

    isToday = DateTime.now();
    past24period = false;

    switch (widget.order.mode.value) {
      //Initialise parameters for asap and scheduled.
      //If the period exceeds the 24 hour mark, a dropdownbutton will be displayed.
      case OrderMode.asap:
        _asapMaximumHour = DateTime.now().hour + 1;
        if (_asapMaximumHour > 23) {
          _asapInitialMinute = DateTime.now().minute ~/ 10;
          _asapMaximumMinute = 5;
          _asapMinimumMinute = DateTime.now().minute ~/ 10;
          _asapMaximumHour = 23;
          _asapMinimumHour = DateTime.now().hour;
          _asapInitialHour = DateTime.now().hour;
          past24period = true;
          selectedDate = DateTime.now();
        } else {
          _asapInitialMinute = DateTime.now().minute ~/ 10;
          _asapMaximumMinute = 5;
          _asapMinimumMinute = DateTime.now().minute ~/ 10;
          _asapMaximumHour = DateTime.now().hour + 1;
          _asapMinimumHour = DateTime.now().hour;
          _asapInitialHour = DateTime.now().hour;
          past24period = false;
          selectedDate = DateTime.now();
        }
        break;
      case OrderMode.scheduled:
        if (widget.order.startDeliveryTime.value.day !=
            widget.order.endDeliveryTime.value.day) {
          _scheduledInitialHour = widget.order.startDeliveryTime.value.hour;
          _scheduledInitialHour = widget.order.startDeliveryTime.value.hour;
          _scheduledInitialMinute =
              widget.order.startDeliveryTime.value.minute ~/ 10;
          _scheduledMaximumMinute = 5;
          _scheduledMinimumMinute =
              widget.order.startDeliveryTime.value.minute ~/ 10;
          _scheduledMaximumHour = 23;
          _scheduledMinimumHour = widget.order.startDeliveryTime.value.hour;
          past24period = true;
          selectedDate = DateTime(
              widget.order.startDeliveryTime.value.year,
              widget.order.startDeliveryTime.value.month,
              widget.order.startDeliveryTime.value.day);
        } else {
          _scheduledInitialHour = widget.order.startDeliveryTime.value.hour;
          _scheduledInitialMinute =
              widget.order.startDeliveryTime.value.minute ~/ 10;
          _scheduledMaximumMinute = 5;
          _scheduledMinimumMinute =
              widget.order.startDeliveryTime.value.minute ~/ 10;
          _scheduledMaximumHour = widget.order.endDeliveryTime.value.hour;
          _scheduledMinimumHour = widget.order.startDeliveryTime.value.hour;
          past24period = false;
          selectedDate = DateTime(
              widget.order.startDeliveryTime.value.year,
              widget.order.startDeliveryTime.value.month,
              widget.order.startDeliveryTime.value.day);
        }
        break;
    }
  }

  //Minute change is dependant on the hour change.
  _handleASAP(num value) {
    if (value != null && value == DateTime.now().hour) {
      setState(() {
        _asapInitialHour = value;
        _asapMaximumMinute = 5;
        _asapMinimumMinute = DateTime.now().minute ~/ 10;
        _asapInitialMinute = DateTime.now().minute ~/ 10;
      });
    } else if (value != null && value == DateTime.now().hour + 1) {
      setState(() {
        _asapInitialHour = value;
        _asapMaximumMinute = DateTime.now().minute ~/ 10;
        _asapMinimumMinute = 0;
        _asapInitialMinute = 0;
      });
    }
  }

  //Minute change is dependant on the hour change.
  _handleSchedule(num value) {
    if (value != null && value == widget.order.startDeliveryTime.value.hour) {
      setState(() {
        _scheduledInitialHour = value;
        _scheduledMaximumMinute = 5;
        _scheduledMinimumMinute =
            widget.order.startDeliveryTime.value.minute ~/ 10;
        _scheduledInitialMinute =
            widget.order.startDeliveryTime.value.minute ~/ 10;
      });
    } else if (value != null &&
        value == widget.order.endDeliveryTime.value.hour) {
      setState(() {
        _scheduledInitialHour = value;
        _scheduledMaximumMinute =
            widget.order.endDeliveryTime.value.minute ~/ 10;
        _scheduledMinimumMinute = 0;
        _scheduledInitialMinute = 0;
      });
    } else {
      setState(() {
        _scheduledInitialHour = value;
        _scheduledMaximumMinute = 5;
        _scheduledMinimumMinute = 0;
        _scheduledInitialMinute = 0;
      });
    }
  }

  _handleScheduledMinuteChanged(value) {
    if (value != null) {
      setState(() {
        _scheduledInitialMinute = value;
      });
    }
  }

  _handleASAPMinuteChanged(value) {
    if (value != null) {
      setState(() {
        _asapInitialMinute = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
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
                      child: _buildPickUpButton(widget.order),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Row _buildDeliveryPeriod(Order order) {
    return Row(
      children: <Widget>[
        StreamBuilder<DateTime>(
          stream: order.startDeliveryTime,
          builder: (context, snap) {
            if (!snap.hasData) return Offstage();
            if (snap.data.day == DateTime.now().day &&
                snap.data.month == DateTime.now().month &&
                snap.data.year == DateTime.now().year) {
              return Container(
                child: Text(
                  snap.hasData ? 'For Today' : "Error",
                  style: FontHelper.semiBold14Black,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            } else {
              return Container(
                child: Text(
                  snap.hasData
                      ? 'For ' +
                          DateTimeHelper.convertDateTimeToDate(snap.data) +
                          ', ' +
                          DateTimeHelper.convertDateTimeToAMPM(snap.data)
                      : "Error",
                  style: FontHelper.regular14Black,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }
          },
        ),
        StreamBuilder<DateTime>(
          stream: order.endDeliveryTime,
          builder: (context, snap) {
            if (!snap.hasData) return Offstage();
            return Material(
              child: Text(
                snap.hasData
                    ? ' - ' + DateTimeHelper.convertDateTimeToAMPM(snap.data)
                    : '',
                style: FontHelper.regular14Black,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
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
                stream: order.orderItems,
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

  Widget _buildPickUpButton(Order order) {
    return StreamBuilder(
      stream: order.mode,
      builder: (context, snap) {
        if (!snap.hasData) return Offstage();
        switch (snap.data) {
          case OrderMode.asap:
            return RaisedButton(
              elevation: 12,
              color: ColorHelper.dabaoOffPaleBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Center(
                child: Text(
                  "Confirm",
                  style: FontHelper.semiBold14White,
                ),
              ),
              onPressed: () async {
                DateTime asapTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  _asapInitialHour,
                  _asapInitialMinute * 10,
                );
                showLoadingOverlay(context: context);
                var isSuccessful = await FirebaseCloudFunctions.acceptRoute(
                  routeID: widget.route.uid,
                  orderID: widget.order.uid,
                  acceptorID:
                      ConfigHelper.instance.currentUserProperty.value.uid,
                  deliveryTime:
                      DateTimeHelper.convertDateTimeToString(asapTime),
                );

                if (isSuccessful) {
                  // Pop t
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                  // TODO bug it doessnt show

                  final snackBar = SnackBar(
                      content: Text(
                          'An Error has occured. Please check your network connectivity'));
                  Scaffold.of(context).showSnackBar(snackBar);
                }
              },
            );
          case OrderMode.scheduled:
            return RaisedButton(
              elevation: 12,
              color: ColorHelper.dabaoOffPaleBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  "Confirm",
                  style: FontHelper.semiBold14White,
                ),
              ),
              onPressed: () async {
                DateTime scheduledTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  _scheduledInitialHour,
                  _scheduledInitialMinute * 10,
                );
                showLoadingOverlay(context: context);
                var isSuccessful = await FirebaseCloudFunctions.acceptRoute(
                  routeID: widget.route.uid,
                  orderID: widget.order.uid,
                  acceptorID:
                      ConfigHelper.instance.currentUserProperty.value.uid,
                  deliveryTime:
                      DateTimeHelper.convertDateTimeToString(scheduledTime),
                );

                if (isSuccessful) {
                  // Pop t
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                  // TODO bug it doessnt show

                  final snackBar = SnackBar(
                      content: Text(
                          'An Error has occured. Please check your network connectivity'));
                  Scaffold.of(context).showSnackBar(snackBar);
                }
              },
            );
            break;
          default:
            return Offstage();
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
    return StreamBuilder(
      stream: order.mode,
      builder: (context, snap) {
        if (!snap.hasData) return Offstage();
        switch (snap.data) {
          case OrderMode.asap:
            integerASAPHourPicker = new HourPicker.hour(
              maxValue: _asapMaximumHour,
              minValue: _asapMinimumHour,
              initialValue: _asapInitialHour,
              step: 1,
              onChanged: (value) {
                _handleASAP(value);
              },
            );

            integerASAPMinutePicker = new MinutePicker.minute(
              maxValue: _asapMaximumMinute,
              minValue: _asapMinimumMinute,
              initialValue: _asapInitialMinute,
              step: 1,
              onChanged: (value) {
                _handleASAPMinuteChanged(value);
              },
            );
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
                integerASAPHourPicker,
                Text(':', style: FontHelper.robotoRegular50Black),
                integerASAPMinutePicker,
                _buildASAPMoreThan24Hour(),
              ],
            );

          case OrderMode.scheduled:
            integerScheduledHourPicker = new HourPicker.hour(
              maxValue: _scheduledMaximumHour,
              minValue: _scheduledMinimumHour,
              initialValue: _scheduledInitialHour,
              step: 1,
              onChanged: (value) {
                _handleSchedule(value);
              },
            );

            integerScheduledMinutePicker = new MinutePicker.minute(
              maxValue: _scheduledMaximumMinute,
              minValue: _scheduledMinimumMinute,
              initialValue: _scheduledInitialMinute,
              step: 1,
              onChanged: (value) {
                _handleScheduledMinuteChanged(value);
              },
            );
            return Row(
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(minHeight: 20, minWidth: 40),
                  child: Text(
                    'I can arrive by: ',
                    style: FontHelper.regular14Black,
                  ),
                ),
                integerScheduledHourPicker,
                Text(':', style: FontHelper.semiBold(Colors.black, 45)),
                integerScheduledMinutePicker,
                _buildScheduledMoreThan24Hour(),
              ],
            );
        }
      },
    );
  }

  _handleScheduledMoreThan24Hour(String value) {
    if (value == 'Today') {
      setState(() {
        _scheduledInitialHour = widget.order.startDeliveryTime.value.hour;
        _scheduledInitialMinute =
            widget.order.startDeliveryTime.value.minute ~/ 10;
        _scheduledMaximumMinute = 5;
        _scheduledMinimumMinute =
            widget.order.startDeliveryTime.value.minute ~/ 10;
        _scheduledMaximumHour = 23;
        _scheduledMinimumHour = widget.order.startDeliveryTime.value.hour;
        selectedDay = value;
      });
      selectedDate = DateTime(
        widget.order.startDeliveryTime.value.year,
        widget.order.startDeliveryTime.value.month,
        widget.order.startDeliveryTime.value.day,
      );
    } else if (value == 'Tomorrow') {
      setState(() {
        _scheduledInitialHour = widget.order.endDeliveryTime.value.hour;
        _scheduledInitialMinute = 0;
        _scheduledMaximumHour = widget.order.endDeliveryTime.value.hour;
        _scheduledMinimumHour = 0;
        _scheduledMinimumMinute = 0;
        _scheduledMaximumMinute =
            widget.order.endDeliveryTime.value.minute ~/ 10;
        selectedDay = value;
      });
      selectedDate = DateTime(
        widget.order.endDeliveryTime.value.year,
        widget.order.endDeliveryTime.value.month,
        widget.order.endDeliveryTime.value.day,
      );
    }
  }

  Widget _buildScheduledMoreThan24Hour() {
    if (past24period == true) {
      return SizedOverflowBox(
        size: Size(85, 50),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              style: FontHelper.regular14Black,
              value: selectedDay,
              onChanged: (value) {
                _handleScheduledMoreThan24Hour(value);
              },
              items: this._dropdownDayMenu,
            ),
          ),
        ),
      );
    } else {
      return Offstage();
    }
  }

  _handleASAPMoreThan24Hour(String value) {
    _asapMaximumHour = DateTime.now().hour + 1;
    if (value == 'Today') {
      setState(() {
        _asapInitialMinute = DateTime.now().minute ~/ 10;
        _asapMaximumMinute = 5;
        _asapMinimumMinute = DateTime.now().minute ~/ 10;
        _asapMaximumHour = 23;
        _asapMinimumHour = DateTime.now().hour;
        _asapInitialHour = DateTime.now().hour;
        selectedDate = DateTime.now();
        selectedDay = value;
      });
    } else if (value == 'Tomorrow') {
      setState(() {
        _asapInitialMinute = 0;
        _asapMaximumMinute = 5;
        _asapMinimumMinute = 0;
        _asapMaximumHour = _asapMaximumHour - 24;
        _asapMinimumHour = 0;
        _asapInitialHour = 0;
        selectedDate = DateTime.now().add(Duration(days: 1));
        selectedDay = value;
      });
    }
  }

  Widget _buildASAPMoreThan24Hour() {
    if (past24period == true) {
      return SizedOverflowBox(
        size: Size(85, 50),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              style: FontHelper.regular14Black,
              value: selectedDay,
              onChanged: (value) {
                _handleASAPMoreThan24Hour(value);
              },
              items: this._dropdownDayMenu,
            ),
          ),
        ),
      );
    } else {
      return Offstage();
    }
  }
}
